#!/usr/bin/env ruby

require "digest"
require "fileutils"
require "pathname"
require "unicode_normalize/normalize"
require "yaml"
require_relative "png_support"

module BookFigure
  module AtlasSupport
    PNG_SIGNATURE = "\x89PNG\r\n\x1A\n".b
    SEMVER = /\A\d+\.\d+\.\d+\z/
    STABLE_ID = /\A[a-z]+(?:[.-][a-z0-9]+)*(?:\/[a-z0-9-]+)?\z/
    PANEL_STATUSES = %w[active deprecated].freeze
    REFERENCE_ROLES = %w[
      primary-form secondary-form interaction style-only avoid
    ].freeze
    SCIENTIFIC_STATUSES = %w[
      unreviewed visual-only reviewed verified deprecated
    ].freeze
    CATEGORIES = %w[
      nucleic-acid protein complex virus chromatin gene-regulation membrane
      compartment organelle plant-structure plant-symptom transport process
      symbol
    ].freeze

    module_function

    def load_yaml(path)
      YAML.safe_load(File.read(path))
    rescue Psych::SyntaxError => error
      raise ArgumentError, "#{path} invalid YAML: #{error.message.lines.first.strip}"
    end

    def load_manifest(root)
      load_yaml(File.join(root, "manifest.yml"))
    end

    def safe_path(root, relative)
      expanded = File.expand_path(relative, root)
      skill_root = File.expand_path("..", root)
      unless expanded == skill_root || expanded.start_with?("#{skill_root}/")
        raise ArgumentError, "path escapes book-figure root: #{relative}"
      end
      expanded
    end

    def panel_records(root)
      manifest = load_manifest(root)
      Array(manifest["panels"])
    end

    def png_dimensions(path)
      File.open(path, "rb") do |io|
        raise ArgumentError, "#{path} invalid PNG signature" unless io.read(8) == PNG_SIGNATURE
        length = io.read(4)&.unpack1("N")
        type = io.read(4)
        unless type == "IHDR" && length == 13
          raise ArgumentError, "#{path} PNG must begin with IHDR"
        end
        io.read(8).unpack("NN")
      end
    end

    def objects(root)
      panel_records(root).flat_map do |panel|
        index_path = safe_path(root, panel.fetch("index"))
        next [] unless File.file?(index_path)

        document = load_yaml(index_path)
        defaults = document["defaults"].is_a?(Hash) ? document["defaults"] : {}
        Array(document["objects"]).map do |object|
          defaults.merge(object).merge(
            "panel_id" => panel.fetch("panel_id"),
            "panel_file" => panel.fetch("file"),
            "panel_width" => panel.fetch("width"),
            "panel_height" => panel.fetch("height")
          )
        end
      end
    end

    def object_index(root)
      objects(root).group_by { |object| object.fetch("object_id") }
    end

    def normalize_term(value)
      value.to_s
        .unicode_normalize(:nfkd)
        .downcase
        .gsub(/[′’]/, "'")
        .gsub(/[^a-z0-9α-ωа-я'*-]+/i, " ")
        .gsub(/\s+/, " ")
        .strip
    end

    def select(root, terms, limit: 8)
      references = selectable_references(root)
      Array(terms).first(limit).map do |term|
        exact = exact_reference_group(references, term)
        if exact
          {
            "requested_name" => term,
            "object_id" => exact.first.fetch("object_id"),
            "match_type" => exact.first.fetch("category") == "complex" ? "composite" : "exact",
            "references" => ranked_references(exact).first(1)
          }
        else
          fallback_references = fallback_references_for(references, term)
          {
            "requested_name" => term,
            "object_id" => "unavailable.#{normalize_term(term).gsub(/\s+/, "-")}",
            "match_type" => "fallback",
            "references" => fallback_references,
            "rationale" => "No exact atlas object; use same-category and interaction exemplars for style only."
          }
        end
      end
    end

    def selectable_references(root)
      objects(root).reject do |reference|
        reference["reference_role"] == "avoid" ||
          %w[deprecated unreviewed].include?(reference["scientific_status"])
      end
    end

    def exact_reference_group(references, term)
      normalized = normalize_term(term)
      matches = references.select do |reference|
        candidates = [
          reference["object_id"],
          reference["printed_label"],
          *Array(reference["aliases"])
        ].map { |candidate| normalize_term(candidate) }
        candidates.include?(normalized)
      end
      return nil if matches.empty?

      object_id = matches
        .group_by { |reference| reference.fetch("object_id") }
        .max_by { |_id, group| group.length }
        .first
      references.select { |reference| reference["object_id"] == object_id }
    end

    def ranked_references(references)
      status_rank = {
        "verified" => 0,
        "reviewed" => 1,
        "visual-only" => 2,
        "unreviewed" => 3,
        "deprecated" => 4
      }
      role_rank = {
        "interaction" => 0,
        "primary-form" => 1,
        "secondary-form" => 2,
        "style-only" => 3,
        "avoid" => 4
      }
      references.sort_by do |reference|
        [
          status_rank.fetch(reference["scientific_status"], 9),
          role_rank.fetch(reference["reference_role"], 9),
          reference.fetch("reference_id")
        ]
      end
    end

    def fallback_references_for(references, term)
      category = inferred_category(term)
      tokens = normalize_term(term).split
      ranked = references.sort_by do |reference|
        category_score = reference["category"] == category ? 0 : 1
        searchable = normalize_term(
          [
            reference["printed_label"],
            *Array(reference["aliases"]),
            *Array(reference["interaction_tags"])
          ].join(" ")
        )
        overlap = tokens.count { |token| searchable.include?(token) }
        [category_score, -overlap, reference.fetch("reference_id")]
      end

      selected = ranked.select { |reference| reference["category"] == category }.first(2)
      interaction = ranked.find do |reference|
        !selected.include?(reference) &&
          Array(reference["interaction_tags"]).any? { |tag| tag.match?(/binding|dna|rna|processing/) }
      end
      selected << interaction if interaction
      selected.compact.first(3)
    end

    def inferred_category(term)
      normalized = normalize_term(term)
      return "protein" if normalized.match?(/helicase|enzyme|protein|factor|polymerase|nuclease|ligase/)
      return "complex" if normalized.match?(/complex|risc|ribosome|spliceosome/)
      return "nucleic-acid" if normalized.match?(/rna|dna|mirna|sirna|pirna|viroid/)
      return "organelle" if normalized.match?(/chloroplast|mitochond|golgi|peroxisome/)
      return "compartment" if normalized.match?(/nucleus|cytoplasm|cytosol|vacuole/)
      return "membrane" if normalized.match?(/membrane|bilayer|tonoplast/)

      "protein"
    end

    def write_selection_report(selections, path)
      report = {
        "queries" => selections.map { |selection| selection.fetch("requested_name") },
        "match_types" => selections.map { |selection| selection.fetch("match_type") },
        "selections" => selections.map do |selection|
          {
            "requested_name" => selection.fetch("requested_name"),
            "object_id" => selection.fetch("object_id"),
            "match_type" => selection.fetch("match_type"),
            "rationale" => selection["rationale"],
            "references" => selection.fetch("references").map do |reference|
              {
                "reference_id" => reference.fetch("reference_id"),
                "panel_id" => reference.fetch("panel_id"),
                "printed_id" => reference["printed_id"],
                "printed_label" => reference.fetch("printed_label"),
                "reference_role" => reference.fetch("reference_role"),
                "scientific_status" => reference.fetch("scientific_status")
              }
            end
          }.compact
        end
      }
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, YAML.dump(report))
      path
    end

    def crop_filename(reference)
      "#{reference.fetch("reference_id").gsub(/[^a-zA-Z0-9]+/, "-").sub(/-\z/, "")}.png"
    end

    def object_crop(root, reference, panel_cache = {})
      panel_path = safe_path(root, reference.fetch("panel_file"))
      image = panel_cache[panel_path] ||= BookFigure::PngImage.read(panel_path)
      x, y, width, height = reference.fetch("object_bbox")
      pixel_x = (x * image.width).floor
      pixel_y = (y * image.height).floor
      pixel_width = [(width * image.width).ceil, 1].max
      pixel_height = [(height * image.height).ceil, 1].max
      padding_x = [(pixel_width * 0.06).ceil, 2].max
      padding_y = [(pixel_height * 0.06).ceil, 2].max
      left = [pixel_x - padding_x, 0].max
      top = [pixel_y - padding_y, 0].max
      right = [pixel_x + pixel_width + padding_x, image.width].min
      bottom = [pixel_y + pixel_height + padding_y, image.height].min
      image.crop(x: left, y: top, width: right - left, height: bottom - top)
    end

    def build_crops(root:, output_dir:)
      FileUtils.mkdir_p(output_dir)
      panel_cache = {}
      objects(root).sort_by { |reference| reference.fetch("reference_id") }.map do |reference|
        output = File.join(output_dir, crop_filename(reference))
        object_crop(root, reference, panel_cache).write(output)
        output
      end
    end

    def build_montage(root:, references:, output:)
      used = references.first(8)
      canvas = BookFigure::PngImage.blank(
        width: 1200,
        height: 600,
        rgba: [255, 249, 239, 255]
      )
      panel_cache = {}
      cell_width = 300
      cell_height = 300

      used.each_with_index do |reference, index|
        crop = object_crop(root, reference, panel_cache).resize_fit(
          max_width: 252,
          max_height: 252
        )
        column = index % 4
        row = index / 4
        x = column * cell_width + (cell_width - crop.width) / 2
        y = row * cell_height + (cell_height - crop.height) / 2
        canvas.paste(crop, x: x, y: y)
      end
      canvas.write(output)
      used
    end

    def validate(root)
      errors = []
      manifest_path = File.join(root, "manifest.yml")
      schema_path = File.join(root, "schema.yml")
      version_path = File.join(root, "VERSION")

      errors << "missing manifest.yml" unless File.file?(manifest_path)
      errors << "missing schema.yml" unless File.file?(schema_path)
      errors << "missing VERSION" unless File.file?(version_path)
      return [errors, { panel_count: 0, reference_count: 0 }] unless errors.empty?

      manifest = load_manifest(root)
      version = manifest["atlas_version"].to_s
      errors << "atlas_version must use semantic versioning" unless version.match?(SEMVER)
      errors << "VERSION must match atlas_version" unless File.read(version_path).strip == version
      errors << "schema_version must be 1" unless manifest["schema_version"] == 1

      panels = Array(manifest["panels"])
      panel_ids = panels.map { |panel| panel["panel_id"] }
      duplicate_values(panel_ids).each { |id| errors << "duplicate panel_id #{id}" }

      panels.each do |panel|
        validate_panel(root, panel, errors)
      end

      references = objects(root)
      reference_ids = references.map { |object| object["reference_id"] }
      duplicate_values(reference_ids.compact).each do |id|
        errors << "duplicate reference_id #{id}"
      end
      references.each { |object| validate_object(object, errors) }

      [errors, { panel_count: panels.length, reference_count: references.length }]
    rescue KeyError, ArgumentError => error
      [[error.message], { panel_count: 0, reference_count: 0 }]
    end

    def validate_panel(root, panel, errors)
      panel_id = panel["panel_id"].to_s
      errors << "invalid panel_id #{panel_id}" unless panel_id.match?(STABLE_ID)
      errors << "#{panel_id} invalid version" unless panel["version"].to_s.match?(SEMVER)
      errors << "#{panel_id} unsupported status #{panel["status"]}" unless PANEL_STATUSES.include?(panel["status"])

      path = safe_path(root, panel.fetch("file"))
      unless File.file?(path)
        errors << "#{panel_id} missing panel file #{panel["file"]}"
        return
      end

      actual_hash = Digest::SHA256.file(path).hexdigest
      errors << "#{panel_id} checksum mismatch" unless actual_hash == panel["sha256"]

      actual_dimensions = png_dimensions(path)
      expected_dimensions = [panel["width"], panel["height"]]
      errors << "#{panel_id} dimensions mismatch" unless actual_dimensions == expected_dimensions

      index_path = safe_path(root, panel.fetch("index"))
      errors << "#{panel_id} missing index #{panel["index"]}" unless File.file?(index_path)
    rescue ArgumentError => error
      errors << "#{panel_id}: #{error.message}"
    end

    def validate_object(object, errors)
      reference_id = object["reference_id"].to_s
      object_id = object["object_id"].to_s
      errors << "invalid reference_id #{reference_id}" unless reference_id.match?(STABLE_ID)
      errors << "#{reference_id} invalid object_id #{object_id}" unless object_id.match?(STABLE_ID)
      errors << "#{reference_id} unsupported category #{object["category"]}" unless CATEGORIES.include?(object["category"])
      errors << "#{reference_id} unsupported reference_role #{object["reference_role"]}" unless REFERENCE_ROLES.include?(object["reference_role"])
      unless SCIENTIFIC_STATUSES.include?(object["scientific_status"])
        errors << "#{reference_id} unsupported scientific_status #{object["scientific_status"]}"
      end
      %w[object_bbox tile_bbox].each do |field|
        validate_bbox(reference_id, field, object[field], errors)
      end
      errors << "#{reference_id} aliases must be a list" unless object["aliases"].is_a?(Array)
      errors << "#{reference_id} interaction_tags must be a list" unless object["interaction_tags"].is_a?(Array)
      errors << "#{reference_id} visual_tags must be a list" unless object["visual_tags"].is_a?(Array)
    end

    def validate_bbox(reference_id, field, bbox, errors)
      unless bbox.is_a?(Array) && bbox.length == 4 && bbox.all? { |value| value.is_a?(Numeric) }
        errors << "#{reference_id} #{field} must contain four numbers"
        return
      end

      x, y, width, height = bbox
      unless x >= 0 && y >= 0 && width.positive? && height.positive? &&
          x + width <= 1 && y + height <= 1
        errors << "#{reference_id} #{field} must stay within normalized panel bounds"
      end
    end

    def duplicate_values(values)
      values.group_by(&:itself).select { |_value, matches| matches.length > 1 }.keys
    end
  end
end

#!/usr/bin/env ruby

require "digest"
require "minitest/autorun"
require "open3"
require "yaml"

require_relative "../scripts/atlas_support"

class AtlasFoundationTest < Minitest::Test
  SKILL_ROOT = File.expand_path("..", __dir__)
  ATLAS_ROOT = File.join(SKILL_ROOT, "atlas")
  MANIFEST = File.join(ATLAS_ROOT, "manifest.yml")
  VALIDATOR = File.join(SKILL_ROOT, "scripts", "validate_atlas.rb")

  def test_manifest_registers_five_immutable_panels
    manifest = YAML.safe_load(File.read(MANIFEST))

    assert_equal "1.0.0", manifest.fetch("atlas_version")
    assert_equal 5, manifest.fetch("panels").length
  end

  def test_all_panels_match_declared_checksums_dimensions_and_object_contract
    errors, summary = BookFigure::AtlasSupport.validate(ATLAS_ROOT)

    assert_empty errors
    assert_equal 5, summary.fetch(:panel_count)
    assert_operator summary.fetch(:reference_count), :>=, 110
  end

  def test_reference_ids_are_unique_while_printed_ids_may_repeat
    objects = BookFigure::AtlasSupport.objects(ATLAS_ROOT)
    reference_ids = objects.map { |object| object.fetch("reference_id") }
    repeated_printed_ids = objects
      .reject { |object| object["printed_id"].to_s.empty? }
      .group_by { |object| object.fetch("printed_id") }
      .values
      .count { |references| references.length > 1 }

    assert_equal reference_ids.length, reference_ids.uniq.length
    assert_operator repeated_printed_ids, :>, 0
  end

  def test_validator_cli_reports_panel_and_reference_counts
    stdout, stderr, status = Open3.capture3(
      "ruby", VALIDATOR,
      "--root", ATLAS_ROOT
    )

    assert status.success?, stderr
    assert_match(/5 panels/, stdout)
    assert_match(/\d+ references/, stdout)
  end
end

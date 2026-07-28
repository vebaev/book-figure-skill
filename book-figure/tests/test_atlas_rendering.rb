#!/usr/bin/env ruby

require "digest"
require "fileutils"
require "minitest/autorun"
require "tmpdir"

require_relative "../scripts/atlas_support"
require_relative "../scripts/png_support"

class AtlasRenderingTest < Minitest::Test
  SKILL_ROOT = File.expand_path("..", __dir__)
  ATLAS_ROOT = File.join(SKILL_ROOT, "atlas")
  PANEL = File.join(
    SKILL_ROOT,
    "assets/object-atlas/panels/panel-001-mirna-silencing.png"
  )

  def test_png_reader_crops_rgba_without_external_dependencies
    image = BookFigure::PngImage.read(PANEL)
    assert_equal [1024, 1024], [image.width, image.height]

    crop = image.crop(x: 10, y: 12, width: 128, height: 96)
    assert_equal [128, 96], [crop.width, crop.height]

    Dir.mktmpdir("book-figure-png") do |temporary|
      output = File.join(temporary, "crop.png")
      crop.write(output)
      assert_equal [128, 96], BookFigure::AtlasSupport.png_dimensions(output)
      assert_equal BookFigure::PngImage.read(output).pixels, crop.pixels
    end
  end

  def test_crop_builder_creates_one_caption_free_crop_per_reference
    Dir.mktmpdir("book-figure-crops") do |temporary|
      outputs = BookFigure::AtlasSupport.build_crops(
        root: ATLAS_ROOT,
        output_dir: temporary
      )

      assert_equal 136, outputs.length
      assert outputs.all? { |path| File.file?(path) }
      assert outputs.none? { |path| File.basename(path).include?("Bio-") }
    end
  end

  def test_crop_build_is_deterministic
    Dir.mktmpdir("book-figure-crops-a") do |first|
      Dir.mktmpdir("book-figure-crops-b") do |second|
        first_outputs = BookFigure::AtlasSupport.build_crops(
          root: ATLAS_ROOT,
          output_dir: first
        )
        second_outputs = BookFigure::AtlasSupport.build_crops(
          root: ATLAS_ROOT,
          output_dir: second
        )

        first_hashes = first_outputs.map { |path| Digest::SHA256.file(path).hexdigest }
        second_hashes = second_outputs.map { |path| Digest::SHA256.file(path).hexdigest }
        assert_equal first_hashes, second_hashes
      end
    end
  end

  def test_montage_is_bounded_to_eight_references
    references = BookFigure::AtlasSupport.objects(ATLAS_ROOT).first(12)

    Dir.mktmpdir("book-figure-montage") do |temporary|
      output = File.join(temporary, "montage.png")
      used = BookFigure::AtlasSupport.build_montage(
        root: ATLAS_ROOT,
        references: references,
        output: output
      )

      assert_equal 8, used.length
      assert_equal [1200, 600], BookFigure::AtlasSupport.png_dimensions(output)
    end
  end
end

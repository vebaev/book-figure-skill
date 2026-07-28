#!/usr/bin/env ruby

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"
require "yaml"

require_relative "../scripts/atlas_support"

class AtlasSelectionTest < Minitest::Test
  SKILL_ROOT = File.expand_path("..", __dir__)
  ATLAS_ROOT = File.join(SKILL_ROOT, "atlas")
  DEBUG_CLI = File.join(SKILL_ROOT, "scripts", "atlas_debug.rb")
  CASES = YAML.safe_load(
    File.read(File.join(__dir__, "atlas-selection-cases.yml"))
  ).fetch("cases")

  def test_exact_composite_and_fallback_selection
    CASES.each do |test_case|
      selections = BookFigure::AtlasSupport.select(
        ATLAS_ROOT,
        test_case.fetch("query")
      )
      expected = test_case.fetch("expected")

      if expected["object_ids"]
        assert_equal expected.fetch("object_ids"),
          selections.map { |selection| selection.fetch("object_id") },
          test_case.fetch("query").join(", ")
      end
      assert_equal expected.fetch("match_types"),
        selections.map { |selection| selection.fetch("match_type") },
        test_case.fetch("query").join(", ")
    end
  end

  def test_composite_match_suppresses_component_only_references
    selections = BookFigure::AtlasSupport.select(
      ATLAS_ROOT,
      ["AGO-containing RISC"]
    )

    assert_equal ["complex.mirisc"],
      selections.map { |selection| selection.fetch("object_id") }
  end

  def test_exact_match_uses_one_best_ranked_reference
    selection = BookFigure::AtlasSupport.select(ATLAS_ROOT, ["Dicer"]).first

    assert_equal "protein.dicer", selection.fetch("object_id")
    assert_equal 1, selection.fetch("references").length
    assert_equal "protein.dicer/p001",
      selection.fetch("references").first.fetch("reference_id")
  end

  def test_fallback_exposes_multiple_style_references
    selection = BookFigure::AtlasSupport.select(
      ATLAS_ROOT,
      ["DNA helicase"]
    ).first

    assert_equal "fallback", selection.fetch("match_type")
    assert_equal "DNA helicase", selection.fetch("requested_name")
    assert_operator selection.fetch("references").length, :>=, 2
  end

  def test_atlas_debug_writes_a_report_and_montage
    Dir.mktmpdir("book-figure-atlas-debug") do |output_dir|
      stdout, stderr, status = Open3.capture3(
        "ruby", DEBUG_CLI,
        "--root", ATLAS_ROOT,
        "--entities", "pre-miRNA,Dicer,AGO-containing RISC,DNA helicase",
        "--output-dir", output_dir
      )

      assert status.success?, stderr
      assert_includes stdout, "atlas-selection-report.yml"
      assert File.file?(File.join(output_dir, "atlas-selection-report.yml"))
      assert File.file?(File.join(output_dir, "atlas-reference-montage.png"))

      report = YAML.safe_load(
        File.read(File.join(output_dir, "atlas-selection-report.yml"))
      )
      assert_equal 4, report.fetch("queries").length
      assert_includes report.fetch("match_types"), "fallback"
    end
  end
end

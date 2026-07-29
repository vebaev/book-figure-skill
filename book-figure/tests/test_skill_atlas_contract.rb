#!/usr/bin/env ruby

require "minitest/autorun"
require "open3"

class SkillAtlasContractTest < Minitest::Test
  SKILL_ROOT = File.expand_path("..", __dir__)
  VALIDATOR = File.join(SKILL_ROOT, "scripts", "validate_skill.rb")

  def test_package_validator_reports_the_visual_atlas_contract
    stdout, stderr, status = Open3.capture3("ruby", VALIDATOR)

    assert status.success?, stderr
    assert_includes stdout, "7 panels"
    assert_includes stdout, "186 references"
    refute_includes stdout, "canonical objects"
  end
end

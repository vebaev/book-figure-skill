#!/usr/bin/env ruby

require "yaml"

root = File.expand_path("..", __dir__)
errors = []

required = %w[
  SKILL.md
  VERSION
  agents/openai.yaml
  assets/genereg-reference.png
  references/design-tokens.md
  references/semantic-colors.md
  tests/contract-cases.yml
]

required.each do |relative|
  path = File.join(root, relative)
  errors << "missing #{relative}" unless File.file?(path)
end

version_path = File.join(root, "VERSION")
if File.file?(version_path)
  version = File.read(version_path).strip
  errors << "VERSION must use semantic versioning" unless version.match?(/\A\d+\.\d+\.\d+\z/)
  errors << "package version must be 1.2.1" unless version == "1.2.1"
end

skill_path = File.join(root, "SKILL.md")
if File.file?(skill_path)
  skill = File.read(skill_path)
  frontmatter = skill.split("---\n", 3)[1]
  metadata = frontmatter ? YAML.safe_load(frontmatter) : {}
  errors << "skill name must be book-figure" unless metadata["name"] == "book-figure"
  errors << "SKILL.md must require design-tokens.md" unless skill.include?("references/design-tokens.md")
  errors << "SKILL.md must require semantic-colors.md" unless skill.include?("references/semantic-colors.md")
end

tokens_path = File.join(root, "references/design-tokens.md")
if File.file?(tokens_path)
  tokens = File.read(tokens_path)
  %w[1600 900 Inter Roboto\ Mono 2.5 64 48 12].each do |token|
    errors << "design tokens missing #{token}" unless tokens.include?(token.gsub("\\", ""))
  end
  errors << "design tokens missing pure-black text color" unless tokens.include?("#000000")
  errors << "design tokens version must be 1.2.0" unless tokens.include?("Version: 1.2.0")
end

colors_path = File.join(root, "references/semantic-colors.md")
if File.file?(colors_path)
  colors = File.read(colors_path)
  %w[#203B57 #5AAFD2 #79B86B #EE8C80 #C7B0E2 #E8DFC7].each do |hex|
    errors << "semantic colors missing #{hex}" unless colors.include?(hex)
  end
  errors << "semantic colors missing pure-black text color" unless colors.include?("#000000")
  errors << "semantic colors version must be 1.1.0" unless colors.include?("Version: 1.1.0")
end

fixture_path = File.join(root, "tests/contract-cases.yml")
if File.file?(fixture_path)
  fixtures = YAML.safe_load(File.read(fixture_path))
  cases = fixtures.is_a?(Hash) ? fixtures["cases"] : nil
  errors << "contract fixtures require at least three cases" unless cases.is_a?(Array) && cases.length >= 3
  mirna_case = cases&.find { |entry| entry["id"] == "mirna-processing" }
  mirna_expected = mirna_case.is_a?(Hash) ? mirna_case["expected"] : nil
  errors << "mirna contract must require Inter for ordinary text" unless mirna_expected&.fetch("default_text_font", nil) == "Inter"
  errors << "mirna contract must require Roboto Mono for nucleotide sequences" unless mirna_expected&.fetch("nucleotide_sequence_font", nil) == "Roboto Mono"
  errors << "mirna contract must require pure-black visible text" unless mirna_expected&.fetch("visible_text_color", nil) == "#000000"
end

asset_path = File.join(root, "assets/genereg-reference.png")
if File.file?(asset_path)
  signature = File.binread(asset_path, 8)
  errors << "reference asset is not a PNG" unless signature == "\x89PNG\r\n\x1A\n".b
  errors << "reference asset must be full-resolution" unless File.size(asset_path) >= 1_000_000
end

agent_path = File.join(root, "agents/openai.yaml")
if File.file?(agent_path)
  agent = YAML.safe_load(File.read(agent_path))
  prompt = agent.dig("interface", "default_prompt").to_s
  errors << "default prompt must invoke $book-figure" unless prompt.include?("$book-figure")
  errors << "default prompt must require Inter" unless prompt.include?("Inter")
  errors << "default prompt must require Roboto Mono" unless prompt.include?("Roboto Mono")
  errors << "default prompt must require pure-black visible text" unless prompt.include?("#000000")
end

active_typography_paths = %w[
  SKILL.md
  agents/openai.yaml
  references/design-tokens.md
  references/semantic-colors.md
]

active_typography_paths.each do |relative|
  path = File.join(root, relative)
  next unless File.file?(path)

  content = File.read(path)
  errors << "#{relative} still references Noto Serif" if content.include?("Noto Serif")
  errors << "#{relative} still references Noto Sans Mono" if content.include?("Noto Sans Mono")
  errors << "#{relative} must require pure-black visible text" unless content.include?("#000000")
end

if errors.empty?
  puts "book-figure validation: PASS"
  exit 0
end

warn "book-figure validation: FAIL"
errors.each { |error| warn "- #{error}" }
exit 1

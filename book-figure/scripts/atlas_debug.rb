#!/usr/bin/env ruby

require "fileutils"
require "optparse"
require_relative "atlas_support"

options = {
  root: File.expand_path("../atlas", __dir__),
  entities: [],
  output_dir: nil
}

OptionParser.new do |parser|
  parser.on("--root PATH") { |value| options[:root] = File.expand_path(value) }
  parser.on("--entities LIST") { |value| options[:entities] = value.split(",").map(&:strip).reject(&:empty?) }
  parser.on("--output-dir PATH") { |value| options[:output_dir] = File.expand_path(value) }
end.parse!

abort "--entities is required" if options[:entities].empty?
abort "--output-dir is required" unless options[:output_dir]

FileUtils.mkdir_p(options[:output_dir])
selections = BookFigure::AtlasSupport.select(options[:root], options[:entities])
report_path = File.join(options[:output_dir], "atlas-selection-report.yml")
montage_path = File.join(options[:output_dir], "atlas-reference-montage.png")
BookFigure::AtlasSupport.write_selection_report(selections, report_path)

references = selections
  .flat_map { |selection| selection.fetch("references") }
  .uniq { |reference| reference.fetch("reference_id") }
BookFigure::AtlasSupport.build_montage(
  root: options[:root],
  references: references,
  output: montage_path
)

puts "book-figure atlas debug: PASS"
puts report_path
puts montage_path

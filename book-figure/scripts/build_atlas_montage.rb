#!/usr/bin/env ruby

require "optparse"
require_relative "atlas_support"

options = {
  root: File.expand_path("../atlas", __dir__),
  reference_ids: [],
  output: nil
}

OptionParser.new do |parser|
  parser.on("--root PATH") { |value| options[:root] = File.expand_path(value) }
  parser.on("--reference-ids IDS") { |value| options[:reference_ids] = value.split(",").map(&:strip) }
  parser.on("--output PATH") { |value| options[:output] = File.expand_path(value) }
end.parse!

abort "--output is required" unless options[:output]
references = BookFigure::AtlasSupport.objects(options[:root])
  .select { |reference| options[:reference_ids].include?(reference.fetch("reference_id")) }
used = BookFigure::AtlasSupport.build_montage(
  root: options[:root],
  references: references,
  output: options[:output]
)
puts "book-figure atlas montage: PASS (#{used.length} references)"

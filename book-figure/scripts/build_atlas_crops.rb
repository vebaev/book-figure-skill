#!/usr/bin/env ruby

require "optparse"
require_relative "atlas_support"

options = {
  root: File.expand_path("../atlas", __dir__),
  output_dir: File.expand_path("../assets/object-atlas/crops", __dir__)
}

OptionParser.new do |parser|
  parser.on("--root PATH") { |value| options[:root] = File.expand_path(value) }
  parser.on("--output-dir PATH") { |value| options[:output_dir] = File.expand_path(value) }
end.parse!

outputs = BookFigure::AtlasSupport.build_crops(
  root: options[:root],
  output_dir: options[:output_dir]
)
puts "book-figure atlas crops: PASS (#{outputs.length} crops)"

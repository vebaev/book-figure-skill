#!/usr/bin/env ruby

require "optparse"
require_relative "atlas_support"

options = {
  root: File.expand_path("../atlas", __dir__),
  entities: []
}

OptionParser.new do |parser|
  parser.on("--root PATH") { |value| options[:root] = File.expand_path(value) }
  parser.on("--entities LIST") { |value| options[:entities] = value.split(",").map(&:strip).reject(&:empty?) }
end.parse!

abort "--entities is required" if options[:entities].empty?
puts YAML.dump(
  "selections" => BookFigure::AtlasSupport.select(
    options[:root],
    options[:entities]
  )
)

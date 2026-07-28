#!/usr/bin/env ruby

require "optparse"
require_relative "atlas_support"

options = {
  root: File.expand_path("../atlas", __dir__)
}

OptionParser.new do |parser|
  parser.on("--root PATH") { |value| options[:root] = File.expand_path(value) }
end.parse!

errors, summary = BookFigure::AtlasSupport.validate(options[:root])

if errors.empty?
  puts "book-figure atlas validation: PASS (#{summary[:panel_count]} panels, #{summary[:reference_count]} references)"
  exit 0
end

warn "book-figure atlas validation: FAIL"
errors.each { |error| warn "- #{error}" }
exit 1

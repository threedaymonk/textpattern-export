#!/usr/bin/env ruby
require "bundler/setup"
require "yaml"

tag = ARGV.first
if ARGV.length > 1
  terms = ARGV.drop(1)
else
  terms = ARGV
end

def generate_headers(hash)
  hash.map{ |k, v| [k, v].join(": ") }.join("\n")
end

def parse_headers(string)
  string.split(/\n/).map { |r| r.split(/:\s+/, 2) }.to_h
rescue => e
  puts string
  raise e
end

Dir['content/posts/**/*'].each do |path|
  next unless File.file?(path)
  header, body = File.read(path).split(/\n\n/, 2)
  metadata = parse_headers(header)
  tags = metadata.fetch('tags', '').split(/\s+/)
  if terms.all? { |t| body.match(Regexp.new(t, 'i')) }
    metadata['tags'] = (tags + [tag]).sort.uniq.join(' ')
    File.open(path, 'w') do |f|
      f << generate_headers(metadata)
      f << "\n\n"
      f << body
    end
  end
end

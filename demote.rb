#!/usr/bin/env ruby
require Dir.home + '/common.rb'
argument = ARGV

candidates = (File.readlines(Dir.home + '/sources/demote.csv'))
path = argument[0]

candidates.each do |line|
  turn = line.split(',')
  $stdout.puts %x[wp user update "#{turn[0]}" --role=subscriber --skip-plugins --skip-themes --url="#{turn[3]}" --path="#{path}"]
end
#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
arguments = ARGV
path = arguments[0]
status = arguments[1]
urls = (File.readlines(Dir.home + '/sources/urls.txt'))

def collate(input)
  input.gsub! /\n/, ','
  interim = input.split(',')
  interim.delete("name")
  interim.delete("version")
  return interim
end

File.open(Dir.home + "/plugins/site-#{status}-plugins.yaml", 'w') do |f|
  f.puts '---'
  urls.each do |line|
    line.chomp!
    line.chop!
    f.puts "#{line}:"
    plugins = %x[wp plugin list --status="#{status}" --skip-plugins=photo-gallery --skip-packages --fields=name,version --path="#{path}" --url="#{line}" --format=csv]
    plugins.strip!
    result = collate(plugins)
    index = 0
    while index < result.length do
      f.puts "  - Plugin: " << "#{result[index]}"
      index += 1
      f.puts "    Version: " << "#{result[index]}"
      index += 1
    end
  end
  f.print '...'
end
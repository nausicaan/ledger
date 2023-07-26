#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
arguments = ARGV
path  = arguments[0]
status = arguments[1]
@writable = ""
urls = (File.readlines(Dir.home + '/sources/urls.txt'))

def append(array)
  array.each do |a|
    @writable << "#{a}\n"
  end
end

def collate(input)
  input.gsub! /\n/, ','
  interim = input.split(',')
  return interim
end

File.open(Dir.home + "/plugins/domain-unfiltered-#{status}-plugins.txt", 'w') do |f|
  writable = []
  urls.each do |line|
    line.chomp!
    line.chop!
    plugins = %x[wp plugin list --status="#{status}" --skip-plugins=photo-gallery --skip-packages --field=name --path="#{path}" --url="#{line}" --format=csv]
    plugins.strip!
    result = collate(plugins)
    append(result)
  end
  f.print @writable
end
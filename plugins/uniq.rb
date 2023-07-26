#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
arguments = ARGV

input = arguments[0]
output = arguments[1]

read = File.readlines(Dir.home + "/#{input}")
read.uniq!
read.sort!
write = File.open(Dir.home + "/#{output}", 'w')

read.each do |line|
  write.puts(line)
end

write.close
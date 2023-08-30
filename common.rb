#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true

# Write a passed variable to a named file
def document(file, content)
  open(Dir.home + file, 'w') do |f|
    f.puts content
  end
end
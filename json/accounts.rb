#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
arguments = ARGV
require 'json'

@compendium = "---\n"
path = arguments[0]
ids = File.readlines(Dir.home + "/smalllist.txt")
@blogs = JSON.parse(File.read(Dir.home + "/sites.json"))
@timestamps = File.read(Dir.home + "/current.json")
# @deletions = ['"', "wp_capabilities", "wp_", "_capabilities", ";b:1;}", "a:0:{}", "a:1:{s:10:", "a:1:{s:13:", "a:1:{s:6:"]

def cleanup(meta)
  meta.gsub!("\n", ",")
  meta.gsub!('"', "")
  meta.gsub!("wp_capabilities", "1")
  meta.gsub!("wp_", "")
  meta.gsub!("_capabilities", "")
  meta.gsub!("a:0:{}", "role blank")
  meta.gsub!("{", "")
  meta.gsub!("}", "")
  meta.gsub!("a:1:", "")
  meta.gsub!("a:2:", "")
  meta.gsub!(";b:1;", "")
  meta.gsub!("s:6:", "")
  meta.gsub!("s:10:", "")
  meta.gsub!("s:12:", "")
  meta.gsub!("s:13:", "")
  meta.gsub!("asset-loader", "")
  meta.chop!
  return meta
end

def grabts(nn, bid)
  count = 1
  response = "No login recorded"
  begin
    rounds = JSON.parse(@timestamps)["#{nn}"].length
  rescue Exception => e
    rounds = 0
    open(Dir.home + "/errors.txt", 'a') do |f|
      f.puts "#{nn}"
    end
  else
    while count < (rounds - 1) do
      if JSON.parse(@timestamps)["#{nn}"][count]['blog_id'] == bid.to_i
        response = JSON.parse(@timestamps)["#{nn}"][count]['timestamp']
      end
      count += 1
    end
  end
  return response
end

def graburl(nums)
  response = "No URL record"
  @blogs.each do |urls|
    if nums.to_s == urls['blog_id']
      response = urls['url']
    end
  end
  return response
end

def stitch(nn)
  iterator = 1
  capacity = @collection.length
  @compendium << "#{nn}:\n"
  @compendium << "  - ID: #{@collection[0]}\n"
  while iterator < capacity do
    @compendium << "  - Blog: #{@collection[iterator]}\n"
    link = graburl(@collection[iterator])
    record = grabts(nn, @collection[iterator])
    @compendium << "    URL: #{link}\n"
    iterator += 1
    @compendium << "    Role: #{@collection[iterator]}\n"
    @compendium << "    Timestamp: " << "#{record}" << "\n"
    iterator += 2
  end
end

ids.each do |line|
  line.chomp!  
  bulk = %x[wp user meta list "#{line}" --url=test.blog.gov.bc.ca --path="#{path}" --format=csv | grep _capabilities]
  if bulk.length > 1
    before = cleanup(bulk)
    @collection = before.split(',')
    nn = %x[wp user get "#{@collection[0]}" --field=login --url=test.blog.gov.bc.ca --path="#{path}"]
    nn.chomp!
    stitch(nn)
  end
end

@compendium << "..."

open(Dir.home + "/compendium.yaml", 'w') do |f|
  f.print "#{@compendium}"
end
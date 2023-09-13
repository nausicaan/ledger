#!/usr/bin/env ruby
arguments = ARGV
require 'yaml'
require Dir.home + '/common.rb'

@simplecsv = "ID,Name,Blog,URL,Role,Timestamp\n"
@compendium = "---\n"
server, path  = arguments[0], arguments[1]
ids = File.readlines(Dir.home + "/sources/everyone.txt")
@blogs = YAML.load_file(Dir.home + '/sources/urls-ids.yaml')

# Filter out extraneous information from the cap variable
def trim_cap(meta)
  deletions = ['"', "wp_", "_capabilities", "a:1:", "a:2:", "s:6:", "s:10:", "s:12:", "s:13:", ";b:1;", "asset-loader", "{", "}"]
  index = 0
  meta.gsub!("\n", ',')
  meta.gsub!('wp_capabilities', '1')
  meta.gsub!('a:0:{}', 'role blank')
  while index < deletions.length do
    meta.gsub!(deletions[index], "")
    index += 1
  end
  @collection = meta.split(',')
end

# Filter out extraneous information from the time variable
def trim_ust(meta)
  @raw = []
  meta.gsub!("\n" , ",")
  collection = meta.split(',')
  collection.each do |line|
    if "#{line}".include? 'wp_user'
      line.sub!('wp_user-settings-time', '0')
    else
      line.sub!('wp_', '')
      line.sub!('_user-settings-time', '')
    end
    line.chomp!
    @raw << "#{line}"
  end
end

# Find the login timestamp that matches the Blog ID
def get_ts(nums)
  response = 0
  index = 0
  while index < @raw.length do
    if nums == @raw[index]
      response = @raw[index + 1]
    end
    index += 1
  end
  return response
end

# Find the URL that matches the Blog ID
def get_url(nums)
  response = 'No URL found'
  @blogs.each do |line|
    if nums.to_i == line['ID']
      response = line['URL']
    end
  end
  return response
end

# Create a variable used to write a csv file
def make_csv(nickname)
  index = 1
  capacity = @collection.length
  while index < capacity do
    @simplecsv << "#{@collection[0]},"
    @simplecsv << "#{nickname},"
    @simplecsv << "#{@collection[index]},"
    link = get_url(@collection[index])
    record = get_ts(@collection[index])
    @simplecsv << "#{link},"
    index += 1
    @simplecsv << "#{@collection[index]},"
    @simplecsv << "#{record}\n"
    index += 2
  end
end

# Piece together the results of the wp user meta list commands into a yaml ready variable
def stitch(nickname)
  index = 1
  capacity = @collection.length
  @compendium << "#{nickname}:\n"
  @compendium << "  - ID: #{@collection[0]}\n"
  while index < capacity do
    @compendium << "  - Blog: #{@collection[index]}\n"
    link = get_url(@collection[index])
    record = get_ts(@collection[index])
    @compendium << "    URL: #{link}\n"
    index += 1
    if @collection[index].length > 20
      @compendium << "    Role: administrator\n"
    else
      @compendium << "    Role: #{@collection[index]}\n"
    end
    @compendium << "    Timestamp: " << "#{record}" << "\n"
    index += 2
  end
end

ids.each do |line|
  line.chomp!  
  cap = %x[wp user meta list "#{line}" --url="#{server}" --path="#{path}" --format=csv | grep _capabilities]
  time = %x[wp user meta list "#{line}" --url="#{server}" --path="#{path}" --format=csv | grep user-settings-time]
  if time.length > 1 || cap.length > 1
    trim_cap(cap)
    trim_ust(time)
    nickname = %x[wp user get "#{@collection[0]}" --field=login --url="#{server}" --path="#{path}"]
    nickname.chomp!
    stitch(nickname)
    make_csv(nickname)
  end
end

@compendium << '...'

document('/results/compendium.csv', @simplecsv)
document('/results/compendium.yaml', @compendium)

# open(Dir.home + '/results/compendium.csv', 'w') do |f|
#   f.print "#{@simplecsv}"
# end

# open(Dir.home + '/results/compendium.yaml', 'w') do |f|
#   f.print "#{@compendium}"
# end
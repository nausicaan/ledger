#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
arguments = ARGV

@path, @server = arguments[0], arguments[1]
@filtered, @nickname, @raw = [], [], []
@unused, @current  = "[", "{"

# Create new files or overwite existing ones
def scribble(name, content)
  open("#{name}", 'w') do |f|
    f.print content
  end
end

# Read filtered-ids and transfer the contents to @filtered
def populate()
  e = File.readlines(Dir.home + "/everyone.txt")
  e.each do |line|
    line.chomp!
    @filtered << "#{line}"
  end
end

# Filter out extraneous information to extract the blod_id
def keto(dump)
  collection = dump.split(',')
  collection.each do |line|
    if "#{line}".include? "wp_user"
      line.sub!("wp_user-settings-time", "0")
    else
      line.sub!("wp_", "")
      line.sub!("_user-settings-time", "")
    end
    line.chomp!
    @raw << "#{line}"
  end
end

# Grep the list of users with site specific login information, and direct those without to @unused
def cycle()
  @filtered.each do |line|
    nn = %x[wp user meta get "#{line}" nickname --url="#{@server}" --path="#{@path}"]
    nn.chomp!
    ust = %x[wp user meta list "#{line}" --url="#{@server}" --path="#{@path}" --format=csv | grep user-settings-time]
    if ust.length > 1
      @nickname << nn
      ust.gsub!("\n" , ",")
      keto(ust)
    else
      @unused << '{"ID":' << "#{line}" << ',"Username":"' << "#{nn}" << '"},'
    end
  end
end

# Create the current.json file using data compiled into @raw
def cook()
  index, nindex = 0, 0
  while index < @raw.length() do
    if "#{@raw[index]}" == "#{@raw[index-3]}"
      @current[-2] = ""
      index += 1
      @current << '{"blog_id": ' << "#{@raw[index]}"
      index += 1
      @current << ',"timestamp": ' << "#{@raw[index]}" << '}],'
      index += 1
    else
      @current << '"' << "#{@nickname[nindex]}" << '":['
      nindex += 1
      @current << '{"ID": ' << "#{@raw[index]}" << '},'
      index += 1
      @current << '{"blog_id": ' << "#{@raw[index]}"
      index += 1
      @current << ',"timestamp": ' << "#{@raw[index]}" << '}],'
      index += 1
    end
  end
end

populate()
cycle()
cook()
@unused.chop!
@current.chop!
@unused << "]"
@current << "}"
scribble(Dir.home + "/unused.json", @unused)
scribble(Dir.home + "/current.json", @current)
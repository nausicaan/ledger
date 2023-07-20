#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
types = ["engage", "events", "forms", "vanity", "workingforyou"]
blog, engage, events, forms, vanity, workingforyou = '"Misc": [', '"Engage": [', '"Events": [', '"Forms": [', '"Vanity": [', '"Workingforyou": ['

e = File.read("blogs.txt")
h = e.split(",")

# Write a passed variable to a named file
def scribble(dest, bunch)
  open(Dir.home + "/#{dest}", 'w') do |f|
    f.print bunch
  end
end

index = 0
while index < h.length() do
  types.each do |line|
    line.chomp!
    if "#{h[index]}".include? "#{line}"
      @variety = "#{line}"
      break
    else
      @variety = "other"
    end
  end
  case @variety
  when "forms"
    forms << '{"URL": "' << "#{h[index]}" << '",'
    index += 1
    forms << '"ID": ' << "#{h[index]}" << '},'
    index += 1
  when "engage"
    engage << '{"URL": "' << "#{h[index]}" << '",'
    index += 1
    engage << '"ID": ' << "#{h[index]}" << '},'
    index += 1
  when "events"
    events << '{"URL": "' << "#{h[index]}" << '",'
    index += 1
    events << '"ID": ' << "#{h[index]}" << '},'
    index += 1
  when "vanity"
    vanity << '{"URL": "' << "#{h[index]}" << '",'
    index += 1
    vanity << '"ID": ' << "#{h[index]}" << '},'
    index += 1
  when "workingforyou"
    workingforyou << '{"URL": "' << "#{h[index]}" << '",'
    index += 1
    workingforyou << '"ID": ' << "#{h[index]}" << '},'
    index += 1
  else
    blog << '{"URL": "' << "#{h[index]}" << '",'
    index += 1
    blog << '"ID": ' << "#{h[index]}" << '},'
    index += 1
  end
end

compile = '{' << blog.chop! << '],' << engage.chop! << '],' << events.chop! << '],' << forms.chop! << '],' << vanity.chop! << '],' << workingforyou.chop! << ']}'
scribble("blogs.json", compile)
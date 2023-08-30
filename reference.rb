#!/usr/bin/env ruby
require Dir.home + '/common.rb'

arguments = ARGV
choice = arguments[0]
list = (File.read(Dir.home + '/sources/blogs.csv'))
@blogs = list.split(',')
ID = '  - ID: '
URL = '    URL: '

# Create a list of all WP sites (Blog ID and URL)
def duo()
  e = "---\n"
  index = 0

  while index < @blogs.length do
      e << "- ID: #{@blogs[index]}\n"
      index += 1
      e << "  URL: #{@blogs[index]}\n"
      index += 1
  end

  e << '...'
  document('/sources/urls-ids.yaml', e)
end

# Create a list of all WP sites (URL only)
def solo()
  content = (File.readlines(Dir.home + '/sources/urls.txt'))
  e = "---\nurls:\n"

  content.each do |line|
    e << "  - #{line}"
  end

  e << "\n..."
  document('/sources/urls.yaml', e)
end

# Create a list of all WP sites (Blog ID and URL) organized by type
def catagory(id, url)
  types = ['test.engage', 'test.events', 'test.forms', 'test.vanity', 'test.workingforyou']
  blog, engage, events, forms, vanity, workingforyou = "Misc:\n", "Engage:\n", "Events:\n", "Forms:\n", "Vanity:\n", "Workingforyou:\n"
  index = 1

  while index < @blogs.length() do
    variety = 'other'
    types.each do |line|
      line.chomp!
      if "#{@blogs[index]}".include? "#{line}"
        variety = "#{line}"
      end
    end

    case variety
    when 'test.forms'
      forms << id << "#{@blogs[index - 1]}\n"
      forms << url << "#{@blogs[index]}\n"
      index += 2
    when 'test.engage'
      engage << id << "#{@blogs[index - 1]}\n"
      engage << url << "#{@blogs[index]}\n"
      index += 2
    when 'test.events'
      events << id << "#{@blogs[index - 1]}\n"
      events << url << "#{@blogs[index]}\n"
      index += 2
    when 'test.vanity'
      vanity << id << "#{@blogs[index - 1]}\n"
      vanity << url << "#{@blogs[index]}\n"
      index += 2
    when 'test.workingforyou'
      workingforyou << id << "#{@blogs[index - 1]}\n"
      workingforyou << url << "#{@blogs[index]}\n"
      index += 2
    else
      blog << id << "#{@blogs[index - 1]}\n"
      blog << url << "#{@blogs[index]}\n"
      index += 2
    end
  end
    
  compile = "---\n" << blog << engage << events << forms << vanity << workingforyou << '...'
  document('/yaml/blog-types.yaml', compile)
end

# Decision tree
case choice
when '-d'
  duo()
when '-s'
  solo()
when '-t'
  catagory(ID, URL)
else
end
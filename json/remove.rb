#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
arguments = ARGV
require 'json'

@path, @server = arguments[0], arguments[1]
@places = JSON.parse(File.read('sites.json'))
@unused = JSON.parse(File.read('unused.json'))
@expired = JSON.parse(File.read('current.json'))

# Write a passed variable to a named file
def scribble(bunch)
  open(Dir.home + "/for-deletion.txt", 'a') do |f|
    f.puts bunch
  end
end

# Filter down the grepped information to only blog_id's
def isolate(bulk)
  triage = []
  collection = bulk.split(',')
  collection.each do |line|
    if "#{line}".include? "_user_level"
      line.sub!("wp_", "")
      line.sub!("_user_level", "")
      line.chomp!
      triage << "#{line}"
    end
  end
  return triage
end

# Clean out any users who have never logged in to a site
def sweep()
  @unused.each do |line|
    uid = "#{line['ID']}"
    bls = %x[wp user meta list "#{line['ID']}" --url="#{@server}" --path="#{@path}" --format=csv | grep wp_]
    bls.gsub!("\n" , ",")
    splat = isolate(bls)
    splat.each do |nums|
      @places.each do |urls|
        if nums == urls['blog_id']
          $stdout.puts %x[wp user delete "#{uid}" --reassign=31 --url="#{urls['url']}" --path="#{@path}"]
        end
      end
    end
  end
end

# Remove users who have not logged in for a certain amount of time
def tidy()
  cutoff = 1640995201
  @expired.each do |line|
    iterator = 1
    uid = "#{line[1][0]['ID']}"
    capacity = @expired["#{line[0]}"].size()
    while iterator < capacity do
      ts = "#{line[1][iterator]['timestamp']}"
      blg1 = "#{line[1][iterator]['blog_id']}"
      if ts.to_i < cutoff
        @places.each do |urls|
          blg2 = "#{urls['blog_id']}"
          if blg1 == blg2
            scribble("Delete user #{uid} with timestamp #{ts} from #{blg2} #{urls['url']}")
            # $stdout.puts %x[wp user delete #{uid} --reassign=31 --url="#{urls['url']}" --path="#{@path}"]
          end
        end
      end
      iterator += 1
    end
  end
end

# Main body of the program
mirage = File.exist?("results/unused.json")

=begin
--Keep this commented out until ready--
  if mirage
    sweep()
  else
    tidy()
  end

=end
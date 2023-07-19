#!/usr/bin/env ruby
$stdin.flush
$stdout.flush
$stdout.sync = true
arguments = ARGV
require 'yaml'

users = YAML.load_file(Dir.home + '/yaml/compendium.yaml')
flag, @server, @path = arguments[0], arguments[1], arguments[2]
@cutoff = 1609459201
@task, @cut = ["Username, URL, Timestamp"], []

# Write a passed variable to a named file
def document(file, content)
  open(Dir.home + file, 'w') do |f|
    f.puts content
  end
end

# Remove all users previously identified
def remove()
  @cut.each do |cuts|
    $stdout.puts %x["#{cuts}"]
  end
end

# Gather a list of potential users to delete
def target(who, ts, uid, where)
  if ts.to_i < @cutoff && where != "http://#{@server}/"
    @task << "#{who},#{where},#{ts}"
    @cut << "wp user delete #{uid} --reassign=31 --url=#{where} --path=#{@path}"
  end
end

# Run the target function for every user instance
users.each do |user|
  index = 1
  capacity = users[user[0]].length
  while index < capacity do
    target(user[0], users[user[0]][index]['Timestamp'], users[user[0]][0]['ID'], users[user[0]][index]['URL'])
    index += 1
  end
end

# Decision tree
case flag
when '-k'
  remove()
when '-c'
  document('/sources/candidates.csv', @task)
else
  $stdout.puts 'Bad flag'
end
#!/usr/bin/env ruby
require 'yaml'
arguments = ARGV
@server, @path = arguments[0], arguments[1]
@task, @cut = ["Username,URL,Timestamp"], []
require Dir.home + '/common.rb'
CUTOFF = 1609459201

# Gather a list of potential users to delete
def target(who, uid, ts, where)
  if ts.to_i < CUTOFF && where != "http://#{@server}/"
    @task << "#{who},#{where},#{ts}"
    @cut << "wp user delete #{uid} --reassign=31 --url=#{where} --path=#{@path}"
  end
end

users = YAML.load_file(Dir.home + '/results/compendium.yaml')

# Run the target function for every user instance
users.each do |user|
  index = 1
  capacity = users[user[0]].length
  while index < capacity do
    target(user[0], users[user[0]][0]['ID'], users[user[0]][index]['Timestamp'], users[user[0]][index]['URL'])
    index += 1
  end
end

document('/sources/candidates.txt', @cut)
document('/sources/candidates.csv', @task)
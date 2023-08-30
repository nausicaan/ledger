#!/usr/bin/env ruby
require Dir.home + '/common.rb'

candidates = (File.readlines(Dir.home + '/sources/promote.txt'))

candidates.each do |line|
  $stdout.puts %x[wp user update "#{line}" --role=editor --skip-plugins --skip-themes --url=test.vanity.blog.gov.bc.ca/embc/ --path=/data/www-app/test_blog_gov_bc_ca/current/web/wp]
end
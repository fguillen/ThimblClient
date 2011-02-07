#!/usr/bin/env ruby

require 'rubygems'
require 'thimbl'

case ARGV[0]
when 'print'
  thimbl = Thimbl.new( '/tmp/plan', '/tmp/thimbl_cache' )
  thimbl.load_data
  puts thimbl.print
when 'fetch'
  thimbl = Thimbl.new( '/tmp/plan', '/tmp/thimbl_cache' )
  thimbl.load_data
  thimbl.fetch
  puts "fetching completed"
when 'post'
  thimbl = Thimbl.new( '/tmp/plan', '/tmp/thimbl_cache' )
  thimbl.load_data
  thimbl.post ARGV[1]
  # thimbl.push
  puts "posted"
end
  
# Thimbl ruby client
#
# Author: fernandoguillen.info
#
# Code: https://github.com/fguillen/ThimblClient
#
# Use:
#     require 'rubygems'
#     require 'thimbl'
#     thimbl =
#       Thimbl::Base.new(
#         'bio'      => 'my bio',
#         'website'  => 'my website', 
#         'mobile'   => 'my mobile', 
#         'email'    => 'my email', 
#         'address'  => 'username@thimbl.net', 
#         'name'     => 'my name'
#       )
#     thimbl.follow 'dk', 'dk@telekommunisten.org'
#     thimbl.fetch
#     thimbl.print
#     thimbl.post 'My first post'
#     thimbl.push <password>
#
module Thimbl
  class Base
    attr_accessor :data
  
    # Initialize a new configuration, the execution of this method
    # will delete any thing in the `thimbl.plan_path` file and `thimbl.cache_path` file.
    #
    # Use:
    #     thimbl =
    #       Thimbl::Base.new(
    #        :bio      => 'bio',
    #        :website  => 'website', 
    #        :mobile   => 'mobile', 
    #        :email    => 'email', 
    #        :address  => 'address', 
    #        :name     => 'name'
    #     )
    #
    # or just:
    #
    #     thimbl = Thimbl::Base.new
    def initialize( opts = {} )
      opts = { 
        'bio'      => 'bio',
        'website'  => 'website', 
        'mobile'   => 'mobile', 
        'email'    => 'email', 
        'address'  => 'address', 
        'name'     => 'name'
      }.merge( opts )
    
      @data = {
        'me'    => opts['address'],
        'plans' => {
          opts['address'] => {
            'name' => opts['name'],
            'bio'  => opts['bio'],
            'properties' => {
              'email'   => opts['email'],
              'mobile'  => opts['mobile'],
              'website' => opts['website']
            },
            'following'  => [],
            'messages'   => [],
            'replies'    => {}
          }
        }
      }
    end
  
    # Post a new message in your time-line.
    # _This method doesn't push the modifications to de server._
    def post( text )
      message = {
        'time' => Time.now.strftime('%Y%m%d%H%M%S'),
        'text' => text
      }

      data['plans'][me]['messages'] << message
    end
    
    # Post a new message in your time-line and push the modifications to the server.
    def post!( text, password )
      post text
      push password
    end
  
    # Add a new user to your following
    # _This method doesn't push the modifications to de server._
    def follow( follow_nick, follow_address )
      return  if data['plans'][me]['following'].count { |e| e['address'] == follow_address } != 0
      data['plans'][me]['following'] << { 'nick' => follow_nick, 'address' => follow_address }
    end
    
    # Add a new user to your following and push the modifications to the server.
    def follow!( follow_nick, follow_address, password )
      follow follow_nick, follow_address
      push password
    end
  
    # Fetch all the info and timelines of all the users you are following.
    # Even you, so any not pushed modification will be overwritten
    def fetch
      following_and_me = following.map { |f| f['address'] } << me
      following_and_me.uniq.each do |address|
        address_finger = Thimbl::Finger.run address
        next  if address_finger.nil? || address_finger.match(/Plan:\s*(.*)/m).nil?
        address_plan = address_finger.match(/Plan:\s*(.*)/m)[1].gsub("\\\n",'')
        data['plans'][address] = JSON.load( address_plan )
      end
    end
    
    # Send your actual `plan` file to your server
    # It requires the password of your thimbl user
    def push( password )
      tmp_path = Thimbl::Utils.to_file plan.to_json
      Net::SCP.start( me.split('@')[1], me.split('@')[0], :password => password ) do |scp|
        scp.upload!( tmp_path, ".plan" )
      end
    end
  
    # Print every message of you and all the users you are following.
    #
    # The method doesn't print anything by it self. It just returns an string
    # with all the comments.
    def print
      result = ""
      messages.each do |message|
        result += Thimbl::Utils.parse_time( message['time'] ).strftime( '%Y-%m-%d %H:%M:%S' )
        result += " #{message['address']}"
        result += " > #{message['text']}"
        result += "\n"
      end
    
      return result
    end
  
    # Returns all the messages of you and all the users you are following
    # in a chronologic order into a json format.
    def messages
      result = []
      
      data['plans'].each_pair do |address, plan|
        next  if plan['messages'].nil?
        plan['messages'].each do |message|
          result << {
            'address' => address,
            'time'    => Thimbl::Utils.parse_time( message['time'] ),
            'text'    => message['text']
          }
        end
      end
      
      result = result.sort { |a,b| a['time'] <=> b['time'] }
    
      return result
    end

    # Returns the actual thimbl user account
    def me
      data['me']
    end
    
    # Returns all the info about the users you are following.
    def following
      data['plans'][me]['following']
    end
    
    # Returns the actual plan
    def plan
      data['plans'][me]
    end
  end
end
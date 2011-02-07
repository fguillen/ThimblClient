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
#         'plan_path'  => '/tmp/plan', 
#         'cache_path' => '/tmp/thimbl_cache',
#         'user'       => 'fguillen@thimblserver.com',
#         'password'   => 'my_thimblserver_password'
#       )
#     thimbl.setup(
#       'bio'      => 'my bio',
#       'website'  => 'my website', 
#       'mobile'   => 'my mobile', 
#       'email'    => 'my email', 
#       'address'  => 'my address', 
#       'name'     => 'my name'
#     )
#     thimbl.follow 'dk', 'dk@telekommunisten.org'
#     thimbl.fetch
#     thimbl.print
#     thimbl.post 'My first post'
#     thimbl.push
#
module Thimbl
  class Base
    attr_reader :plan_path, :cache_path, :data, :address, :user, :password
  
    # Initialize the thimbl client.
    #
    # Use:
    #     Thimbl.new(
    #       :plan_path  => <path to the plan file>,
    #       :cache_path => <path to the cache file>
    #       :user       => <the user@domain>,
    #       :password   => <the user password>
    #     )
    #
    def initialize( opts = {} )
      @plan_path = opts['plan_path']
      @cache_path = opts['cache_path']
      @user = opts['user']
      @password = opts['password']
    
      @data = nil
      @address = nil
    end
  
    # Setup a new configuration, the execution of this method
    # will delete any thing in the `thimbl.plan_path` file and `thimbl.cache_path` file.
    #
    # Use:
    #     thimbl.setup(
    #        :bio      => 'bio',
    #        :website  => 'website', 
    #        :mobile   => 'mobile', 
    #        :email    => 'email', 
    #        :address  => 'address', 
    #        :name     => 'name'
    #     )
    #
    def setup( opts = {} )
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

      @address = opts['address']
    
      save_data
    end
  
    # Post a new message in your time-line.
    #
    # Use:
    #     thimbl.post <message>
    #
    # To publish your comment you have to call:
    #     thimbl.push
    #
    def post( text )
      message = {
        'address' => address,
        'time' => Time.now.strftime('%Y%m%d%H%M%S'),
        'text' => text
      }

      data['plans'][address]['messages'] << message
      save_data
    end
  
    # Add a new user to follow
    #
    # Use:
    #     thimbl.follow 'nick', 'address'
    #
    # To publish your following users you have to call:
    #     thimbl.push
    #
    def follow( follow_nick, follow_address )
      data['plans'][address]['following'] << { 'nick' => follow_nick, 'address' => follow_address }
      save_data
    end
  
    # Fetch all the info and timelines of all the users you are following.
    #
    # Use:
    #     thimbl.fetch
    #
    def fetch
      following.map { |f| f['address'] }.each do |followed_address|
        address_finger = Thimbl::Finger.run followed_address
        address_plan = address_finger.match(/Plan:\s*(.*)/m)[1].gsub("\\\n",'')
        data['plans'][followed_address] = JSON.load( address_plan )
      end
    
      save_data
    end
  
    # Print every message of you and all the users you are following.
    #
    # Use:
    #     thimbl.print
    # The method doesn't print anything by it self. It just returns an string
    # with all the comments.
    #
    def print
      result = ""
      messages.each do |message|
        result += Thimbl::Base.parse_time( message['time'] ).strftime( '%Y-%m-%d %H:%M:%S' )
        result += " #{message['address']}"
        result += " > #{message['text']}"
        result += "\n"
      end
    
      return result
    end
  
    # Send your actual `plan` file to your server
    #
    # Use:
    #     thimbl.push
    #
    def push
      Net::SCP.start( user.split('@')[1], user.split('@')[0], :password => password ) do |scp|
        scp.upload!( plan_path, ".plan" )
      end
    end

    # Charge into the `thimbl` object all the data into your `cache` file.
    # Use:
    #     thimbl.load_data
    #
    def load_data
      @data = JSON.load( File.read cache_path )
      @address = data['me']
    end
  
    # Save all the data into the `thimbl` objecto into your `cache` file and
    # `plan` file.
    #
    # Use:
    #     thimbl.save_data
    #
    def save_data
      File.open( cache_path, 'w' ) { |f| f.write data.to_json }
      File.open( plan_path, 'w' ) { |f| f.write data['plans'][address].to_json }
    end
  
    # Returns all the info about the users you are following.
    #
    # Use:
    #     thimbl.following
    #
    def following
      data['plans'][address]['following']
    end
  
    # Returns all the messages of you and all the users you are following
    # in a chronologic order into a json format.
    #
    # Use:
    #     thimbl.messages
    #
    def messages
      _messages = data['plans'].values.map { |e| e['messages'] }.flatten
      _messages = _messages.sort { |a,b| a['time'] <=> b['time'] }
    
      return _messages
    end
  
    def self.parse_time( time )
      Time.utc( time[0,4], time[4,2], time[6,2], time[8,2], time[10,2], time[12,2] )
    end
  end
end
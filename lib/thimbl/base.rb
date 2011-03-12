# Thimbl ruby client
#
# Author: fernandoguillen.info
# Code: https://github.com/fguillen/ThimblClient
# Use:
#     require 'rubygems'
#     require 'thimbl'
#     thimbl =
#       Thimbl::Base.new(
#         'user@thimbl.net',
#         {
#           :bio      => 'my bio',
#           :website  => 'my website', 
#           :mobile   => 'my mobile', 
#           :email    => 'my email', 
#           :name     => 'my name'
#         }
#       )
#     thimbl.follow 'dk', 'dk@telekommunisten.org'
#     thimbl.fetch
#     thimbl.messages
#     thimbl.post 'My first post'
#     thimbl.push 'password'
#
module Thimbl
  class NoPlanException < Exception; end
  class Base
    attr_accessor :data, :address
  
    # Initialize a new configuration
    #
    # Use:
    #     thimbl =
    #       Thimbl::Base.new(
    #         'user@thimbl.net', 
    #         {  
    #           :bio      => 'bio',
    #           :website  => 'website', 
    #           :mobile   => 'mobile', 
    #           :email    => 'email', 
    #           :name     => 'name'
    #         }
    #       )
    #
    # or just:
    #
    #     thimbl = Thimbl::Base.new( 'user@thimbl.net' )
    def initialize( address, opts = {} )
      @address = address
      @data = {
        'name' => opts[:name],
        'bio'  => opts[:bio],
        'properties' => {
          'email'   => opts[:email],
          'mobile'  => opts[:mobile],
          'website' => opts[:website]
        },
        'following'  => [],
        'messages'   => [],
        'replies'    => {}
      }
    end
  
    # Post a new message in user's time-line.
    # _This method doesn't push the modifications to de server._
    def post( text )
      message = {
        'time' => Time.now.strftime('%Y%m%d%H%M%S'),
        'text' => text
      }

      data['messages'] << message
    end
    
    # Post a new message in user's time-line and push the modifications to the server.
    def post!( text, password )
      post text
      push password
    end
  
    # Add a new user to user's following
    # _This method doesn't push the modifications to de server._
    def follow( follow_nick, follow_address )
      return  if following.count { |e| e.address == follow_address } != 0
      data['following'] << { 'nick' => follow_nick, 'address' => follow_address }
    end
    
    # Add a new user to user's following and push the modifications to the server.
    def follow!( follow_nick, follow_address, password )
      follow follow_nick, follow_address
      push password
    end
  
    # Remove a user from the user's following
    # _This method doesn't push the modifications to de server._
    def unfollow( follow_address )
      data['following'].delete_if { |e| e['address'] == follow_address }
    end
  
    # Remove a new from user's following and push the modifications to the server.
    def unfollow!( follow_address, password )
      unfollow follow_address
      push password
    end
  
    # Updating cached .plan
    # Any not pushed modification will be deleted
    def fetch
      @data = JSON.load( fetch_plan )
    end
    
    # Send user's cached .plan to user's server
    # It requires the password of user's thimbl user
    def push( password )
      tmp_path = Thimbl::Utils.to_file( data.to_json )
      Net::SCP.start( address.split('@')[1], address.split('@')[0], :password => password ) do |scp|
        scp.upload!( tmp_path, ".plan" )
      end
    end
  
    # Returns all this user's messages 
    # in a chronologic order.
    def messages
      return []  if data['messages'].nil?
      
      result = []
      
      data['messages'].each do |message|
        result << OpenStruct.new({
          :address => address,
          :time    => Thimbl::Utils.parse_time( message['time'] ),
          :text    => message['text']
        })
      end
      
      result = result.sort { |a,b| a.time <=> b.time }
    
      return result
    end
    
    # Returns all the info about the users this user is following.
    def following
      return []  if data['following'].nil?
      
      result = []
      
      data['following'].each do |chased|
        result << OpenStruct.new({
          :nick    => chased['nick'],
          :address => chased['address']
        })
      end
      
      return result
    end
    
    # Returns all the user properties
    def properties
      OpenStruct.new({
        :bio      => data['bio'],
        :name     => data['name'],
        :email    => data['properties']['email'],
        :mobile   => data['properties']['mobile'],
        :website  => data['properties']['website']
      })
    end
    
    # Update all the user properties
    # _This method doesn't push the modifications to de server._
    def properties=( opts = {} )
      data['bio']                   = opts[:bio]      unless opts[:bio].nil?
      data['name']                  = opts[:name]     unless opts[:name].nil?
      data['properties']['email']   = opts[:email]    unless opts[:email].nil?
      data['properties']['mobile']  = opts[:mobile]   unless opts[:mobile].nil?
      data['properties']['website'] = opts[:website]  unless opts[:website].nil?
    end
    
    private
    
      def fetch_plan
        finger_response = Thimbl::Finger.run address
      
        if( finger_response.nil? || finger_response.match(/Plan:\s*(.*)/m).nil? )
          raise NoPlanException, 'Not Thimbl Plan in this address'
        end
      
        finger_plan = finger_response.match(/Plan:\s*(.*)/m)[1].gsub("\\\n",'')
      
        return finger_plan
      end
      
  end
end
require 'rubygems'
require 'json'
require "#{File.dirname(__FILE__)}/finger"

class Thimbl
  attr_reader :plan_path, :cache_path, :data, :address
  
  def initialize( plan_path, cache_path )
    @plan_path = plan_path
    @cache_path = cache_path
    @data = nil
    @address = nil
  end
  
  def setup( opts = {} )
    opts = { 
      :bio      => 'bio',
      :website  => 'website', 
      :mobile   => 'mobile', 
      :email    => 'email', 
      :address  => 'address', 
      :name     => 'name'
    }.merge( opts )
    
    @data = {
      'me'    => opts[:address],
      'plans' => {
        opts[:address] => {
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
      }
    }

    @address = opts[:address]
    
    save_data
    
    return self
  end
  
  def post( text )
    load_data

    message = {
      :address => address,
      :time => Time.now.strftime('%Y%m%d%H%M%S'),
      :text => text
    }
          
    data['plans'][address]['messages'] << message
    save_data
    
    return self
  end
  
  def follow( follow_nick, follow_address )
    load_data
    data['plans'][address]['following'] << { :nick => follow_nick, :address => follow_address }
    save_data
    
    return self
  end
  
  def fetch
    load_data

    following.map { |f| f['address'] }.each do |followed_address|
      address_finger = Finger.run followed_address
      address_plan = address_finger.match(/Plan:\s*(.*)/m)[1].gsub("\n",'')
      data['plans'][followed_address] = JSON.load( address_plan )
    end
    
    save_data
    
    return self
  end
  
  def print
    load_data
    
    result = ""
    messages.each do |message|
      result += Thimbl.parse_time( message['time'] ).strftime( '%Y-%m-%d %H:%M:%S' )
      result += " #{message['address']}"
      result += " > #{message['text']}"
      result += "\n"
    end
    
    return result
  end
  
  def load_data
    @data = JSON.load( File.read cache_path )
    @address = data['me']
  end
  
  def save_data
    File.open( cache_path, 'w' ) { |f| f.write data.to_json }
    File.open( plan_path, 'w' ) { |f| f.write data['plans'][address].to_json }
  end
  
  def following
    data['plans'][address]['following']
  end
  
  def messages
    _messages = data['plans'].values.map { |e| e['messages'] }.flatten
    _messages = _messages.sort { |a,b| a['time'] <=> b['time'] }
    
    return _messages
  end
  
  def self.parse_time( time )
    Time.utc( time[0,4], time[4,2], time[6,2], time[8,2], time[10,2], time[12,2] )
  end
end
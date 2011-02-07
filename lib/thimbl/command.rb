module Thimbl
  class Command 
    CONFIG_FILE = File.expand_path( "~#{ENV['USER']}/.thimbl/thimbl.cnf" )
    
    def self.setup( *args )
      if( args.size != 4 )
        raise ArgumentError, "use: $ thimbl setup <plan_path> <cache_path> <thimbl_user> <thimbl_password>"
      end
    
      FileUtils.mkdir_p File.dirname( config_file )
      
      File.open( config_file, 'w' ) do |f|
        f.write( { :plan_path => args[0], :cache_path => args[1], :user => args[2], :password => args[3] }.to_json )
      end
    
      thimbl = Thimbl::Command.load
      thimbl.setup( 'address' => args[2] )
    end
  
    def self.print
      thimbl = Thimbl::Command.load
      thimbl.load_data
      return thimbl.print
    end
  
    def self.fetch
      thimbl = Thimbl::Command.load
      thimbl.load_data
      thimbl.fetch
    end
  
    def self.post( text )
      if( text.nil? || text.empty? )
        raise ArgumentError, "use: $ thimbl post <message>"
      end
      thimbl = Thimbl::Command.load
      thimbl.load_data
      thimbl.post text
    end
  
    def self.push
      thimbl = Thimbl::Command.load
      thimbl.load_data
      thimbl.push
    end
  
    def self.follow( nick, address )
      if( nick.nil? || nick.empty? || address.nil? || address.empty? )
        raise ArgumentError, "use: $ thimbl follow <nick> <address>"
      end
      thimbl = Thimbl::Command.load
      thimbl.load_data
      thimbl.follow nick, address
    end
  
    def self.load
      if( !File.exists? config_file )
        raise ArgumentError, "Thimbl need to setup, use: $ thimbl setup <plan_path> <cache_path> <thimbl_user> <thimbl_password>"
      end
    
      config = JSON.load( File.read config_file )
      thimbl = Thimbl::Base.new( config )

      return thimbl
    end
    
    def self.config_file
      CONFIG_FILE
    end
  end
end
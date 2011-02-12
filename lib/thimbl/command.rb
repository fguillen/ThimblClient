module Thimbl
  class Command 
    CACHE_PATH = File.expand_path( "~#{ENV['USER']}/.thimbl/cache.json" )
    
    def self.setup( *args )
      if( args.size != 1 )
        raise ArgumentError, "use: $ thimbl setup <thimbl_user>"
      end
    
      thimbl = Thimbl::Base.new( 'address' => args[0] )
      save_cache thimbl.data
    end
    
    def self.save_cache data
      if !File.exists? File.dirname( cache_path )
        FileUtils.mkdir_p File.dirname( cache_path )
      end

      File.open( cache_path, 'w' ) do |f|
        f.write( data.to_json )
      end
    end

    def self.print
      thimbl = Thimbl::Command.load
      return thimbl.print
    end
  
    def self.fetch
      thimbl = Thimbl::Command.load
      thimbl.fetch
      save_cache thimbl.data
    end
  
    def self.post( text )
      if( text.nil? || text.empty? )
        raise ArgumentError, "use: $ thimbl post <message>"
      end
      thimbl = Thimbl::Command.load
      thimbl.post text
      save_cache thimbl.data
    end
    
    def self.push( password )
      if( password.nil? || password.empty? )
        raise ArgumentError, "use: $ thimbl push <password>"
      end
      thimbl = Thimbl::Command.load
      thimbl.push password
    end
  
    def self.follow( nick, address )
      if( nick.nil? || nick.empty? || address.nil? || address.empty? )
        raise ArgumentError, "use: $ thimbl follow <nick> <address>"
      end
      thimbl = Thimbl::Command.load
      thimbl.follow nick, address
      save_cache thimbl.data
    end
  
    def self.load
      if( !File.exists? cache_path )
        raise ArgumentError, "Thimbl need to setup, use: $ thimbl setup <thimbl_user>"
      end
    
      thimbl = Thimbl::Base.new 
      thimbl.data = JSON.load File.read cache_path

      return thimbl
    end
    
    def self.cache_path
      CACHE_PATH
    end
  end
end
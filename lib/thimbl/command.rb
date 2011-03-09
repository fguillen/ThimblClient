module Thimbl
  class Command 
    THIMBL_FOLDER = File.expand_path( "~#{ENV['USER']}/.thimbl" )
    
    def self.version
      "0.2.0"
    end
    
    def self.setup( *args )
      if( args.size != 1 )
        raise ArgumentError, "use: $ thimblr setup <thimbl_user>"
      end
      
      if !File.exists? File.dirname( thimbl_folder )
        FileUtils.mkdir_p File.dirname( thimbl_folder )
      end
    
      save_actual args[0]
    end

    def self.print
      thimbl = get_actual
      thimbl.fetch
      
      # user's messages
      messages = thimbl.messages
      
      # user's following's messages
      thimbl.following.each do |followed|
        thimbl = Thimbl::Base.new followed.address
        begin
          thimbl.fetch
          messages += thimbl.messages
        rescue Thimbl::NoPlanException
          puts "Error fetching #{followed.address} messages"
        end
      end
      
      messages = messages.sort { |a,b| a.time <=> b.time }
      
      result = ""
      messages.each do |message|
        result += message.time.strftime( '%Y-%m-%d %H:%M:%S' )
        result += " #{message.address}"
        result += " > #{message.text}"
        result += "\n"
      end
    
      return result
    end
  
    def self.post( text = nil, password = nil)
      if( text.nil? || text.empty? || password.nil? )
        raise ArgumentError, "use: $ thimblr post <message> <password>"
      end
      
      thimbl = get_actual
      thimbl.post! text, password
    end
  
    def self.follow( nick = nil, address = nil, password = nil )
      if( nick.nil? || nick.empty? || address.nil? || address.empty? || password.nil? )
        raise ArgumentError, "use: $ thimblr follow <nick> <address> <password>"
      end
      
      thimbl = get_actual
      thimbl.follow! nick, address, password
    end
    
    private
   
      def self.save_actual( address )
        File.open( "#{thimbl_folder}/actual", 'w' ) { |f| f.write address }
      end
    
      def self.get_actual
        if( !File.exists? "#{thimbl_folder}/actual" )
          raise ArgumentError, "Thimbl need to setup, use: $ thimblr setup <thimbl_user>"
        end
      
        thimbl = Thimbl::Base.new File.read( "#{thimbl_folder}/actual" )
        thimbl.fetch
      
        return thimbl
      end
    
      def self.thimbl_folder
        THIMBL_FOLDER
      end
  end
end
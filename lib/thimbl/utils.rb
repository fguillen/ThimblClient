module Thimbl
  class Utils
    def self.to_file( text )
      file = Tempfile.new('plan.json')
      file.write( text )
      file.close
      file.path
    end
    
    def self.parse_time( time )
      Time.utc( time[0,4], time[4,2], time[6,2], time[8,2], time[10,2], time[12,2] )
    end
  end
end
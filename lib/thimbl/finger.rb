module Thimbl
  class Finger
    # Wrapper for `finger` system call
    def self.run( *args )
      %x[`which finger` #{args.join(' ')}]
    end
  end
end
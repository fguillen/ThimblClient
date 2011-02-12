module Thimbl
  class Finger
    # Wrapper for `finger` system call
    def self.run( *args )
      %x[`whereis finger` #{args.join(' ')}]
    end
  end
end
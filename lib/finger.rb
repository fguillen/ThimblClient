class Finger
  def self.run( *args )
    %x[`whereis finger` #{args.join(' ')}]
  end
end
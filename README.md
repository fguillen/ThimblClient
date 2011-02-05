# Thimbl Client

Is an small client for the distributed microbloging protocol: [thimbl](http://www.thimbl.net/)

## Version

This version is in development, not ready for any production environment.

## Install

   gem install thimbl
   
## Use

    require 'thimbl'
    thimbl = Thimbl.new( '/tmp/plan', '/tmp/thimbl_cache' )
    thimbl.setup(
      :bio      => 'my bio',
      :website  => 'my website', 
      :mobile   => 'my mobile', 
      :email    => 'my email', 
      :address  => 'my address', 
      :name     => 'my name'
    )
    thimbl.follow 'dk', 'dk@telekommunisten.org'
    thimbl.fetch
    thimbl.print
    thimbl.post 'My first post'
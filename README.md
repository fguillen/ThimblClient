# Thimbl Client

Is an small client for the distributed microbloging protocol: [thimbl](http://thimbl.net/)

I have follow the style of the [Thimbl Python client](https://github.com/blippy/Thimbl-CLI) in many ways. 

## Commands

* setup
* follow
* fetch
* post
* print

## Architecture

This client is only manipulating json files, the one with your **personal plan** and the other with the **complete cache** of the timeline of the people you are following.

## Version

This version is in development, not ready for any production environment.

## Install

    gem install thimbl
   
## Use

    require 'rubygems'
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
    
## TODO

* Document a little bit the methods and the architecture
* Command **push**
* Shell script /bin/thimbl

# Thimbl Client

Is an small client for the distributed microbloging protocol: [thimbl](http://thimbl.net/)

I have follow the style of the [Thimbl Python client](https://github.com/blippy/Thimbl-CLI) in many ways. 

## Commands

* fetch
* follow
* post
* push

## Attributes

* messages
* following
* properties

## Version

This version is in development, use it in production environment under your own responsability.

## Install

    gem install thimbl
   
## Use

    require 'rubygems'
    require 'thimbl'
    thimbl =
      Thimbl::Base.new(
        'user@thimbl.net',
        {
          :bio      => 'my bio',
          :website  => 'my website', 
          :mobile   => 'my mobile', 
          :email    => 'my email', 
          :name     => 'my name'
        }
      )
    thimbl.follow 'dk', 'dk@telekommunisten.org'
    thimbl.fetch
    thimbl.messages
    thimbl.post 'My first post'
    thimbl.push 'password'
    
## Shell Command

The gem comes with a *shell command*, you can use it like this:
    
    thimblr setup 'user@thimblrserver.com'
    thimblr follow 'dk' 'dk@telekommunisten.org' 'my password'
    thimblr print
    thimblr post 'My first message :)' 'my password'
    
## TODO

* Support *simbolize* hash keys
* Reply to another message support
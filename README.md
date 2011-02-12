# Thimbl Client

Is an small client for the distributed microbloging protocol: [thimbl](http://thimbl.net/)

I have follow the style of the [Thimbl Python client](https://github.com/blippy/Thimbl-CLI) in many ways. 

## Commands

* follow
* fetch
* post
* print
* push

## Architecture

This client is only manipulating json files, the one with your **personal plan** and the other with the **complete cache** of the timeline of the people you are following.

## Version

This version is in development, not ready for any production environment.

## Install

    gem install thimbl
   
## Use

    require 'rubygems'
    require 'thimbl'
    thimbl = 
      Thimbl::Base.new(
        'bio'      => 'my bio',
        'website'  => 'my website', 
        'mobile'   => 'my mobile', 
        'email'    => 'my email', 
        'address'  => 'me@thimbl.net', 
        'name'     => 'my name'
      )
    thimbl.follow 'dk', 'dk@telekommunisten.org'
    thimbl.fetch
    thimbl.print
    thimbl.post 'My first post'
    thimbl.push 'password'
    
## Shell Command

The gem comes with a *shell command*, you can use it like this:
    
    thimblr setup 'user@thimblrserver.com'
    thimblr follow 'dk' 'dk@telekommunisten.org'
    thimblr fetch
    thimblr print
    thimblr post "My first message :)"
    thimblr push <password>
    
## TODO

* Support *simbolize* hash keys
* In the Thimbl::Command.setup ask for the rest of the configuration options *bio*, *mobile*, ...
* thimbl.unfollow
* ERROR: If finger respond empty Plan
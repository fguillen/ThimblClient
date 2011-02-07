# Thimbl Client

Is an small client for the distributed microbloging protocol: [thimbl](http://thimbl.net/)

I have follow the style of the [Thimbl Python client](https://github.com/blippy/Thimbl-CLI) in many ways. 

## Commands

* setup
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
        'plan_path'  => '/tmp/plan', 
        'cache_path' => '/tmp/thimbl_cache',
        'user'       => 'fguillen@thimblserver.com',
        'password'   => 'my_thimblserver_password'
      )
    thimbl.setup(
      'bio'      => 'my bio',
      'website'  => 'my website', 
      'mobile'   => 'my mobile', 
      'email'    => 'my email', 
      'address'  => 'my address', 
      'name'     => 'my name'
    )
    thimbl.follow 'dk', 'dk@telekommunisten.org'
    thimbl.fetch
    thimbl.print
    thimbl.post 'My first post'
    thimbl.push
    
## Shell Command

The gem comes with a *shell command*, you can use it like this:

    thimbl setup ~/thimbl_plan ~/thimbl_cache 'user@thimblserver.com' 'thimblpass'
    thimbl follow 'dk' 'dk@telekommunisten.org'
    thimbl fetch
    thimbl print
    thimbl post "My first message :)"
    thimbl push
    
## TODO

* Shell script /bin/thimbl
* Thinking that the *plan_path* is not needed.
* Not save thimbl password, request for it in any *thimbl.push*
* Support *simbolize* hash keys
* In the Thimbl::Command.setup ask for the rest of the configuration options *bio*, *mobile*, ...
* thimbl.unfollow
* ERROR: If finger respond empty Plan
* ERROR: the message format is without *address* key.
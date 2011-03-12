require "#{File.dirname(__FILE__)}/test_helper"

class ThimblBaseTest < Test::Unit::TestCase
  def setup
    @data = {
      'me'    => 'my address',
      'plans' => {
        'my address' => {
          'name' => 'my name',
          'bio'  => 'my bio',
          'properties' => {
            'email'   => 'my email',
            'mobile'  => 'my mobile',
            'website' => 'my website'
          },
          'following'  => [],
          'messages'   => [],
          'replies'    => {}
        }
      }
    }
  end
  
  def teardown
  end
  
  def test_new_without_options
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    
    assert_equal 'user@thimbl.net', thimbl.address
    assert_equal nil  , thimbl.properties.name
    assert_equal []   , thimbl.messages
    assert_equal nil  , thimbl.properties.bio
    assert_equal []   , thimbl.following
    assert_equal nil  , thimbl.properties.mobile
    assert_equal nil  , thimbl.properties.website
    assert_equal nil  , thimbl.properties.email
  end
  
  def test_new_with_options
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
    
    assert_equal 'user@thimbl.net'  , thimbl.address
    assert_equal 'my name'          , thimbl.properties.name
    assert_equal 'my bio'           , thimbl.properties.bio
    assert_equal 'my mobile'        , thimbl.properties.mobile
    assert_equal 'my website'       , thimbl.properties.website
    assert_equal 'my email'         , thimbl.properties.email
  end
  
  def test_post
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    
    Delorean.time_travel_to("2011-02-03 04:05:06") do
      thimbl.post( "wadus wadus" )
    end

    message = thimbl.messages.last
    assert_equal '20110203040506', message.time.strftime('%Y%m%d%H%M%S')
    assert_equal 'wadus wadus', message.text
  end
  
  def test_post!
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.expects( :post ).with( 'wadus wadus' )
    thimbl.expects( :push ).with( 'password' )
    
    thimbl.post! 'wadus wadus', 'password'
  end
  
  def test_follow
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    
    thimbl.follow( 'nick', 'address' )
    
    followed = thimbl.following.last
    assert_equal( 'nick', followed.nick )
    assert_equal( 'address', followed.address )
  end
  
  def test_follow!
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.expects( :follow ).with( 'nick', 'new@thimbl.net' )
    thimbl.expects( :push ).with( 'password' )
    
    thimbl.follow! 'nick', 'new@thimbl.net', 'password'
  end
  
  def test_unfollow
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.data = JSON.load File.read "#{FIXTURES_PATH}/following.json"
    
    assert_equal 2, thimbl.following.size
  
    thimbl.unfollow 'rw@telekommunisten.org'
    
    assert_equal 1, thimbl.following.size
  end
  
  def test_unfollow!
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.expects( :unfollow ).with( 'new@thimbl.net' )
    thimbl.expects( :push ).with( 'password' )
    
    thimbl.unfollow! 'new@thimbl.net', 'password'
  end
  
  def test_fetch
    finger_fixture = File.read "#{FIXTURES_PATH}/finger_dk_telekommunisten_org.txt"
    Thimbl::Finger.expects(:run).with( 'me@thimbl.net' ).returns( finger_fixture )
      
    thimbl = Thimbl::Base.new 'me@thimbl.net'
    thimbl.fetch
    
    assert_equal( 21, thimbl.messages.size )
  end
  
  def test_fetch_with_plan_with_two_break_lines
    finger_fixture = File.read "#{FIXTURES_PATH}/finger_dk_telekommunisten_org_two_break_lines.txt"
    Thimbl::Finger.expects(:run).with( 'me@thimbl.net' ).returns( finger_fixture )
    
    thimbl = Thimbl::Base.new 'me@thimbl.net'
    thimbl.fetch
    
    assert_equal( 22, thimbl.messages.size )
  end
  
  def test_fetch_with_not_plan
    Thimbl::Finger.expects(:run).with( 'me@thimbl.net' ).returns( 'no plan' )
    
    thimbl = Thimbl::Base.new 'me@thimbl.net'
    
    assert_raise(Thimbl::NoPlanException) do
      thimbl.fetch
    end
  end
  
  def test_push
    thimbl = Thimbl::Base.new 'user@domain.com'
    Net::SCP.expects(:start).with( 'domain.com', 'user', :password => 'my password' )
    thimbl.push 'my password'
  end
    
  def test_messages
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.data = JSON.load File.read "#{FIXTURES_PATH}/messages_1.json"

    assert_equal( 2, thimbl.messages.size )
    
    first = thimbl.messages.first
    last = thimbl.messages.last
    
    assert_equal 'user@thimbl.net', first.address
    assert_equal 'messages_1 b', first.text
    assert_equal '20100707125120', first.time.strftime('%Y%m%d%H%M%S')
    
    assert_equal 'user@thimbl.net', last.address
    assert_equal 'messages_1 a', last.text
    assert_equal '20101105124412', last.time.strftime('%Y%m%d%H%M%S')
  end
  
  def test_messages_when_plan_has_not_messages
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.data = JSON.load File.read "#{FIXTURES_PATH}/no_messages.json"
    
    assert_equal [], thimbl.messages
  end
  
  def test_following
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.data = JSON.load File.read "#{FIXTURES_PATH}/following.json"

    assert_equal( 2, thimbl.following.size )
    
    first = thimbl.following.first
    last = thimbl.following.last
    
    assert_equal 'mike@mikepearce.net', first.address
    assert_equal 'mike', first.nick
    
    assert_equal 'rw@telekommunisten.org', last.address
    assert_equal 'rico', last.nick
  end
  
  def test_following_when_plan_has_not_following
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.data = JSON.load File.read "#{FIXTURES_PATH}/no_following.json"
    
    assert_equal [], thimbl.following
  end
    
  def test_parse_time
    assert_equal( Time.utc( 2010, 11, 29, 6, 3, 35 ), Thimbl::Utils.parse_time( '20101129060335' ) )
  end
  
  def test_not_adding_a_following_if_already_there
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    thimbl.follow 'wadus', 'wadus@thimbl.net'
    thimbl.follow 'wadus', 'wadus@thimbl.net'
    
    assert_equal( 1, thimbl.following.size )
  end
end
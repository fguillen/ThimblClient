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
    thimbl = Thimbl::Base.new
    
    assert_equal( 'address', thimbl.me )
    
    data = thimbl.data['plans'][thimbl.me]
    assert_equal( 'name', data['name'] )
    assert_equal( [], data['messages'] )
    assert_equal( 'bio', data['bio'] )
    assert_equal( {}, data['replies'] )
    assert_equal( [], data['following'] )
    assert_equal( 'mobile', data['properties']['mobile'] )
    assert_equal( 'website', data['properties']['website'] )
    assert_equal( 'email', data['properties']['email'] )
  end
  
  def test_new_with_options
    thimbl = 
      Thimbl::Base.new(
        'bio'      => 'my bio',
        'website'  => 'my website', 
        'mobile'   => 'my mobile', 
        'email'    => 'my email', 
        'address'  => 'my address', 
        'name'     => 'my name'
      )
    
    assert_equal( 'my address', thimbl.me )
    
    data = thimbl.data['plans'][thimbl.me]
    assert_equal( 'my name', data['name'] )
    assert_equal( 'my bio', data['bio'] )
    assert_equal( 'my mobile', data['properties']['mobile'] )
    assert_equal( 'my website', data['properties']['website'] )
    assert_equal( 'my email', data['properties']['email'] )
  end
  
  def test_post
    thimbl = Thimbl::Base.new
    
    Delorean.time_travel_to("2011-02-03 04:05:06") do
      thimbl.post( "wadus wadus" )
    end

    message = thimbl.data['plans'][thimbl.me]['messages'].last
    assert_equal( '20110203040506', message['time'] )
    assert_equal( 'wadus wadus', message['text'] )
  end
  
  def test_follow
    thimbl = Thimbl::Base.new
    
    thimbl.follow( 'nick', 'address' )
    
    following = thimbl.data['plans'][thimbl.me]['following'].last
    assert_equal( 'nick', following['nick'] )
    assert_equal( 'address', following['address'] )
  end
  
  def test_fetch
    finger_fixture = File.read "#{File.dirname(__FILE__)}/fixtures/finger_dk_telekommunisten_org.txt"
    finger_sequence = sequence('finger_sequence')
      
    Thimbl::Finger.
      expects(:run).
      with( 'wadus1@telekommunisten.org' ).
      returns( finger_fixture ).
      in_sequence( finger_sequence )
      
    Thimbl::Finger.
      expects(:run).
      with( 'wadus2@telekommunisten.org' ).
      returns( finger_fixture ).
      in_sequence( finger_sequence )
      
    Thimbl::Finger.
      expects(:run).
      with( 'me@thimbl.net' ).
      returns( finger_fixture ).
      in_sequence( finger_sequence )
      
    thimbl = Thimbl::Base.new( 'address' => 'me@thimbl.net' )
    thimbl.expects(:following).returns( [ 
      {'nick' => 'wadus1', 'address' => 'wadus1@telekommunisten.org' },
      {'nick' => 'wadus2', 'address' => 'wadus2@telekommunisten.org' },
    ] )
  
    thimbl.fetch
    
    assert_equal( 21, thimbl.data['plans']['wadus1@telekommunisten.org']['messages'].count )
    assert_equal( 21, thimbl.data['plans']['wadus2@telekommunisten.org']['messages'].count )
  end
  
  def test_fetch_with_plan_with_two_break_lines
    finger_fixture = File.read "#{File.dirname(__FILE__)}/fixtures/finger_dk_telekommunisten_org_two_break_lines.txt"
    Thimbl::Finger.expects(:run).with( 'me@thimbl.net' ).returns( finger_fixture )
    
    thimbl = Thimbl::Base.new( 'address' => 'me@thimbl.net' )
    thimbl.fetch
    
    assert_equal( 22, thimbl.data['plans']['me@thimbl.net']['messages'].count )
  end
  
  def test_push
    thimbl = Thimbl::Base.new( 'address' => 'user@domain.com' )
    Net::SCP.expects(:start).with( 'domain.com', 'user', :password => 'my password' )
    thimbl.push 'my password'
  end
    
  def test_messages
    thimbl = Thimbl::Base.new
    thimbl.data = JSON.load File.read "#{File.dirname(__FILE__)}/fixtures/cache.json"
    
    assert_equal( 24, thimbl.messages.size )
  end
  
  def test_print
    messages = [ 
      { 
        "address" => "fguillen@telekommunisten.org",
        "text"    => "Here I am",
        "time"    => "20110131002202"
      },
      { 
        "address" => "fguillen@telekommunisten.org",
        "text"    => "testing :)",
        "time"    => "20110205150637"
      }
    ]
    
    thimbl = Thimbl::Base.new
    thimbl.expects( :messages ).returns( messages )
    
    print = thimbl.print

    assert_equal( 2, print.lines.to_a.size )
    assert_equal( "2011-01-31 00:22:02 fguillen@telekommunisten.org > Here I am\n", print.lines.to_a[0] )
    assert_equal( "2011-02-05 15:06:37 fguillen@telekommunisten.org > testing :)\n", print.lines.to_a[1] )
  end
    
  def test_parse_time
    assert_equal( Time.utc( 2010, 11, 29, 6, 3, 35 ), Thimbl::Utils.parse_time( '20101129060335' ) )
  end
  
  def test_not_adding_a_following_if_already_there
    thimbl = Thimbl::Base.new
    thimbl.follow 'wadus', 'wadus@thimbl.net'
    thimbl.follow 'wadus', 'wadus@thimbl.net'
    
    assert_equal( 1, thimbl.following.size )
  end
end
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
  
  def test_new
    thimbl = 
      Thimbl::Base.new( 
        'plan_path'  => 'plan_path', 
        'cache_path' => 'cache_path',
        'user'       => 'user',
        'password'   => 'password'
      )
      
    assert_equal( 'plan_path', thimbl.plan_path )
    assert_equal( 'cache_path', thimbl.cache_path )
    assert_equal( 'user', thimbl.user )
    assert_equal( 'password', thimbl.password )
  end
  
  def test_setup_without_options
    thimbl = Thimbl::Base.new
    thimbl.expects(:save_data)
    thimbl.setup
    
    assert_equal( 'address', thimbl.address )
    
    data = thimbl.data['plans'][thimbl.address]
    assert_equal( 'name', data['name'] )
    assert_equal( [], data['messages'] )
    assert_equal( 'bio', data['bio'] )
    assert_equal( {}, data['replies'] )
    assert_equal( [], data['following'] )
    assert_equal( 'mobile', data['properties']['mobile'] )
    assert_equal( 'website', data['properties']['website'] )
    assert_equal( 'email', data['properties']['email'] )
  end
  
  def test_setup_with_options
    thimbl = Thimbl::Base.new
    thimbl.expects(:save_data)
    thimbl.setup(
      'bio'      => 'my bio',
      'website'  => 'my website', 
      'mobile'   => 'my mobile', 
      'email'    => 'my email', 
      'address'  => 'my address', 
      'name'     => 'my name'
    )
    
    assert_equal( 'my address', thimbl.address )
    
    data = thimbl.data['plans'][thimbl.address]
    assert_equal( 'my name', data['name'] )
    assert_equal( 'my bio', data['bio'] )
    assert_equal( 'my mobile', data['properties']['mobile'] )
    assert_equal( 'my website', data['properties']['website'] )
    assert_equal( 'my email', data['properties']['email'] )
  end
  
  def test_post
    Thimbl::Base.any_instance.expects(:save_data)
    thimbl = Thimbl::Base.new
    
    thimbl.stubs( :address ).returns( @data['me'] )
    thimbl.stubs( :data ).returns( @data )
    
    Delorean.time_travel_to("2011-02-03 04:05:06") do
      thimbl.post( "wadus wadus" )
    end

    message = thimbl.data['plans'][thimbl.address]['messages'].last
    assert_equal( thimbl.address, message['address'] )
    assert_equal( '20110203040506', message['time'] )
    assert_equal( 'wadus wadus', message['text'] )
  end
  
  def test_follow
    Thimbl::Base.any_instance.expects(:save_data)
    thimbl = Thimbl::Base.new
    thimbl.stubs( :address ).returns( @data['me'] )
    thimbl.stubs( :data ).returns( @data )
    
    thimbl.follow( 'nick', 'address' )
    
    following = thimbl.data['plans'][thimbl.address]['following'].last
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
      
    Thimbl::Base.any_instance.expects(:save_data)
    
    thimbl = Thimbl::Base.new
    thimbl.stubs(:data).returns( @data )
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
    Thimbl::Finger.
      expects(:run).
      with( 'wadus1@telekommunisten.org' ).
      returns( finger_fixture )
      
    Thimbl::Base.any_instance.expects(:save_data)
    
    thimbl = Thimbl::Base.new
    thimbl.stubs(:data).returns( @data )
    thimbl.expects(:following).returns( [{'nick' => 'wadus1', 'address' => 'wadus1@telekommunisten.org' }] )
    
    thimbl.fetch
    
    assert_equal( 22, thimbl.data['plans']['wadus1@telekommunisten.org']['messages'].count )
  end
  
  def test_push
    thimbl = Thimbl::Base.new( 'user' => 'user@domain', 'password' => 'my password' )
    Net::SCP.expects(:start).with( 'domain', 'user', :password => 'my password' )
    thimbl.push
  end
  
  def test_load_data
    thimbl = Thimbl::Base.new( 'cache_path' => "#{File.dirname(__FILE__)}/fixtures/cache.json" )
    thimbl.load_data
    
    assert_equal( 'fguillen@telekommunisten.org', thimbl.data['me'] )
    assert_equal( 2, thimbl.data['plans'].size )
    assert_equal( 4, thimbl.data['plans']['fguillen@telekommunisten.org']['messages'].size )
  end
  
  def test_messages
    thimbl = Thimbl::Base.new( 'cache_path' => "#{File.dirname(__FILE__)}/fixtures/cache.json" )
    thimbl.load_data
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
  
  def test_save_data
    thimbl = Thimbl::Base.new( 'plan_path' => '/tmp/plan_path', 'cache_path' => '/tmp/cache_path' )
    thimbl.stubs( :address ).returns( @data['me'] )
    thimbl.stubs( :data ).returns( @data )
    thimbl.data
    thimbl.save_data
    
    assert_equal( thimbl.data['plans'][thimbl.address], JSON.load( File.read '/tmp/plan_path' ) )
    assert_equal( thimbl.data, JSON.load( File.read '/tmp/cache_path' ) )
  end
  
  def test_parse_time
    assert_equal( Time.utc( 2010, 11, 29, 6, 3, 35 ), Thimbl::Base.parse_time( '20101129060335' ) )
  end
end
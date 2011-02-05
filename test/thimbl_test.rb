require "#{File.dirname(__FILE__)}/../thimbl"
require 'test/unit'
require 'mocha'
require 'ruby-debug'

class ThimblTest < Test::Unit::TestCase
  def setup
    @plan_path = '/tmp/plan'
    @cache_path = '/tmp/cache'
  end
  
  def teardown
    File.delete( @plan_path )   if File.exists? @plan_path
    File.delete( @cache_path )  if File.exists? @cache_path
  end
  
  def test_new
    thimbl = Thimbl.new( 'plan_path', 'cache_path' )
    assert_equal( 'plan_path', thimbl.plan_path )
    assert_equal( 'cache_path', thimbl.cache_path )
  end
  
  def test_setup_without_options
    thimbl = Thimbl.new( @plan_path, @cache_path )
    thimbl.setup
    
    puts "XXX: plan: #{File.read @plan_path }"
  end
  
  def test_setup_with_options
    thimbl = Thimbl.new( @plan_path, @cache_path )
    thimbl.setup(
      :bio      => 'my bio',
      :website  => 'my website', 
      :mobile   => 'my mobile', 
      :email    => 'my email', 
      :address  => 'my address', 
      :name     => 'my name'
    )
    
    puts "XXX: plan: #{File.read @plan_path }"
  end
  
  def test_post
    thimbl = Thimbl.new( @plan_path, @cache_path )
    thimbl.setup
    thimbl.post( "wadus wadus" )
    
    puts "XXX: plan: #{File.read @plan_path }"
    puts "XXX: cache: #{File.read @cache_path }"
  end
  
  def test_follow
    thimbl = Thimbl.new( @plan_path, @cache_path )
    thimbl.setup
    thimbl.follow( 'nick', 'address' )

    puts "XXX: plan: #{File.read @plan_path }"
    puts "XXX: cache: #{File.read @cache_path }"
  end
  
  def test_fetch
    thimbl = Thimbl.new( @plan_path, @cache_path )
    thimbl.setup
    thimbl.expects(:following).returns( [ {'nick' => 'pepe', 'address' => 'dk@telekommunisten.org' } ] )
    
    puts thimbl.fetch
    
    puts "XXX: plan: #{File.read @plan_path }"
    puts "XXX: cache: #{File.read @cache_path }"
  end
  
  def test_messages
    thimbl = Thimbl.new( @plan_path, "#{File.dirname(__FILE__)}/fixtures/cache.json" )
    thimbl.load_data
    puts thimbl.messages
  end
  
  def test_print
    thimbl = Thimbl.new( @plan_path, "#{File.dirname(__FILE__)}/fixtures/cache.json" )
    thimbl.load_data
    
    puts thimbl.print
  end
  
  def test_parse_time
    assert_equal( Time.utc( 2010, 11, 29, 6, 3, 35 ), Thimbl.parse_time( '20101129060335' ) )
  end
end
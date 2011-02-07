require "#{File.dirname(__FILE__)}/test_helper"

class CommandTest < Test::Unit::TestCase
  def setup
  end
  
  def teardown
  end
  
  def test_setup_should_exit_if_parameters_not_correct
    assert_raise( ArgumentError ) do
      Thimbl::Command.setup
    end
  end
  
  def test_setup
    Thimbl::Command.stubs( :config_file ).returns( '/tmp/.thimbl/config_file' )
    Thimbl::Command.expects( :load ).returns( Thimbl::Base.new )
    Thimbl::Base.any_instance.expects( :setup )
    
    Thimbl::Command.setup( 'plan_path', 'cache_path', 'user', 'password' )

    config_written = JSON.load( File.read( '/tmp/.thimbl/config_file' ) )
    
    assert_equal( 'plan_path', config_written['plan_path'] )
    assert_equal( 'cache_path', config_written['cache_path'] )
    assert_equal( 'user', config_written['user'] )
    assert_equal( 'password', config_written['password'] )
    
    FileUtils.remove_dir '/tmp/.thimbl'
  end
  
  def test_print
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :load_data )
    thimbl.expects( :print )
    
    Thimbl::Command.print
  end
  
  def test_fetch
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :load_data )
    thimbl.expects( :fetch )

    Thimbl::Command.fetch
  end
  
  def test_post_should_raise_error_if_wrong_parameters
    assert_raise( ArgumentError ) do
      Thimbl::Command.post
    end
  end
  
  def test_post
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :load_data )
    thimbl.expects( :post ).with( 'wadus' )
    
    Thimbl::Command.post 'wadus'
  end
  
  def test_push
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :load_data )
    thimbl.expects( :push )
    
    Thimbl::Command.push
  end
  
  def test_follow_should_raise_error_if_wrong_parameters
    assert_raise( ArgumentError ) do
      Thimbl::Command.follow
    end
  end
    
  def test_follow
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :load_data )
    thimbl.expects( :follow ).with( 'wadus', 'wadus@domain.com' )

    Thimbl::Command.follow 'wadus', 'wadus@domain.com'
  end
  
  def test_load_should_raise_error_if_not_config_file
    Thimbl::Command.stubs( :config_file ).returns( '/tmp/not_exists_file' )
    
    assert_raise( ArgumentError ) do
      Thimbl::Command.load
    end
  end
  
  def test_load
    Thimbl::Command.stubs( :config_file ).returns( '/tmp/config_file' )
    File.expects( :exists? ).with( '/tmp/config_file' ).returns( true )
    File.expects( :read ).with( '/tmp/config_file' ).returns( "{ \"a\" : 1 }" )
    Thimbl::Base.expects( :new ).with( { 'a' => 1 } )

    Thimbl::Command.load
  end
end
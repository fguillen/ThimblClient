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
    temp_file = Tempfile.new('cache.json')
    Thimbl::Command.stubs( :cache_path ).returns( temp_file.path )
    Thimbl::Command.setup( 'me@thimbl.net' )

    cache_written = JSON.load temp_file.read
    assert_equal 'me@thimbl.net', cache_written['me']
    
    temp_file.unlink
  end
  
  def test_print
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :print )
    
    Thimbl::Command.print
  end
  
  def test_fetch
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
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
    thimbl.expects( :post ).with( 'wadus' )
    
    Thimbl::Command.post 'wadus'
  end
  
  def test_push
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :push ).with( 'pass' )
    
    Thimbl::Command.push 'pass'
  end
  
  def test_follow_should_raise_error_if_wrong_parameters
    assert_raise( ArgumentError ) do
      Thimbl::Command.follow
    end
  end
    
  def test_follow
    thimbl = Thimbl::Base.new
    Thimbl::Command.expects( :load ).returns( thimbl )
    thimbl.expects( :follow ).with( 'wadus', 'wadus@domain.com' )

    Thimbl::Command.follow 'wadus', 'wadus@domain.com'
  end
  
  def test_load_should_raise_error_if_not_config_file
    Thimbl::Command.stubs( :cache_path ).returns( '/tmp/not_exists_file' )
    
    assert_raise( ArgumentError ) do
      Thimbl::Command.load
    end
  end
  
  def test_load
    temp_file = Tempfile.new 'cache.json'
    temp_file.write "{ \"a\" : 1 }"
    temp_file.close
    
    Thimbl::Command.stubs( :cache_path ).returns( temp_file.path )

    thimbl = Thimbl::Command.load
    
    assert_equal 1, thimbl.data['a']
    
    temp_file.unlink
  end
end
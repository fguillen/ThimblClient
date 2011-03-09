require "#{File.dirname(__FILE__)}/test_helper"

class CommandTest < Test::Unit::TestCase
  def setup
  end
  
  def teardown
  end
  
  def test_get_actual
    temp_folder = Dir.tmpdir
    
    File.open( "#{temp_folder}/actual", 'w' ) { |f| f.write 'user@thimbl.net' }
    
    Thimbl::Command.stubs( :thimbl_folder ).returns( temp_folder )
    Thimbl::Base.any_instance.expects( :fetch )
    
    thimbl = Thimbl::Command.get_actual
    
    assert_equal 'user@thimbl.net', thimbl.address
  end
  
  def test_get_actual_with_not_existing_file
    Thimbl::Command.stubs( :thimbl_folder ).returns( '/not_exists' )
    
    assert_raise( ArgumentError ) do
      Thimbl::Command.get_actual
    end
  end
  
  def test_save_actual
    temp_folder = "#{Dir.tmpdir}/.thimbl"
    FileUtils.mkdir_p temp_folder
    Thimbl::Command.stubs( :thimbl_folder ).returns( temp_folder )
    
    Thimbl::Command.save_actual 'user@thimbl.net'
    
    assert_equal 'user@thimbl.net', File.read( "#{temp_folder}/actual" )
  end
  
  def test_setup_should_exit_if_parameters_not_correct
    assert_raise( ArgumentError ) do
      Thimbl::Command.setup
    end
  end
  
  def test_setup
    temp_folder = "#{Dir.tmpdir}/.thimbl"
    Thimbl::Command.expects( :thimbl_folder ).returns( temp_folder )
    Thimbl::Command.expects( :save_actual ).with( 'me@thimbl.net' )
    
    Thimbl::Command.setup( 'me@thimbl.net' )

    assert File.directory? temp_folder
  end
  
  def test_print
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    Thimbl::Command.expects( :get_actual ).returns( thimbl )
    Thimbl::Base.any_instance.expects( :fetch_plan ).times( 3 ).returns(
      File.read( "#{FIXTURES_PATH}/messages_1.json" ), # the user
      File.read( "#{FIXTURES_PATH}/messages_2.json" ), # following 1
      File.read( "#{FIXTURES_PATH}/messages_3.json" )  # following 2
    )
    
    assert_equal File.read( "#{FIXTURES_PATH}/print.txt" ), Thimbl::Command.print
  end
  
  def test_post_should_raise_error_if_wrong_parameters
    assert_raise( ArgumentError ) do
      Thimbl::Command.post
    end
  end
  
  def test_post_should_raise_error_if_not_password
    assert_raise( ArgumentError ) do
      Thimbl::Command.post "message"
    end
  end
  
  def test_post
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    Thimbl::Command.expects( :get_actual ).returns( thimbl )
    thimbl.expects( :post! ).with( 'wadus', 'password' )
    
    Thimbl::Command.post 'wadus', 'password'
  end
    
  def test_follow_should_raise_error_if_wrong_parameters
    assert_raise( ArgumentError ) do
      Thimbl::Command.follow
    end
  end
    
  def test_follow
    thimbl = Thimbl::Base.new 'user@thimbl.net'
    Thimbl::Command.expects( :get_actual ).returns( thimbl )
    thimbl.expects( :follow! ).with( 'wadus', 'wadus@domain.com', 'password' )

    Thimbl::Command.follow 'wadus', 'wadus@domain.com', 'password'
  end
end
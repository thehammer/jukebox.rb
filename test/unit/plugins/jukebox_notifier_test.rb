require File.expand_path(File.dirname(__FILE__) +  '/../unit_test_helper')
require 'jukebox_notifier'

class JukeboxNotifierTest < Test::Unit::TestCase
  MOCK_HOST = "http://mock.host:port/ci"
  
  def setup
    @notifier = JukeboxNotifier.new
    @notifier.jukeboxes = [ MOCK_HOST ]
  end
  
  test "default_jukebox is empty array if no shared settings detected" do
    assert_equal nil, JukeboxNotifier.default_jukebox
  end
  
  test "default_jukebox is default jukebox in an array if set" do
    JukeboxNotifier.stubs(:shared_settings).returns("default_jukebox" => :jukebox_app_url)
    assert_equal :jukebox_app_url, JukeboxNotifier.default_jukebox
  end
  
  test "initialize create jukebox notifier logger" do
    Logger.expects(:new).with("#{RAILS_ROOT}/log/jukebox_notifier.log")
    JukeboxNotifier.new
  end
  
  test "initialize assiges new logger to logger instance variable" do
    Logger.expects(:new).returns(:a_logger)
    assert_equal :a_logger, JukeboxNotifier.new.logger
  end
  
  test "that Net HTTP get_reponse errors are logged" do
    Net::HTTP.stubs(:get_response).raises(Exception)
    jukebox_notifier = JukeboxNotifier.new
    logger = stub
    logger.expects(:error)
    jukebox_notifier.stubs(:logger).returns(logger)
    jukebox_notifier.jukeboxes = ["a jukebox"]
    jukebox_notifier.build_started(nil)
  end

  test "project jukebox has only the default one if none is specified" do
    JukeboxNotifier.stubs(:default_jukebox).returns(:another_host)
    notifier = JukeboxNotifier.new
    assert_equal [:another_host], notifier.jukeboxes
  end
  
  test "app jukeboxes is initially empty array if no default is specified" do
    JukeboxNotifier.stubs(:default_jukebox).returns(nil)
    notifier = JukeboxNotifier.new
    assert_equal [], notifier.jukeboxes
  end
    
  test "build started" do
    build = stub_everything()
    URI.expects(:parse).with(MOCK_HOST + "/hammertime/add_for/build_started").returns(:uri)
    Net::HTTP.expects(:get_response).with(:uri)
    @notifier.build_started build
  end
  
  test "build successful" do
    build = stub_everything(:successful? => true)
    URI.expects(:parse).with(MOCK_HOST + "/hammertime/add_for/build_successful").returns(:uri)
    Net::HTTP.expects(:get_response).with(:uri)
    
    @notifier.build_finished build
  end
  
  test "build failed" do
    build = stub_everything(:successful? => false)
    URI.expects(:parse).with(MOCK_HOST + "/hammertime/add_for/build_failed").returns(:uri)
    Net::HTTP.expects(:get_response).with(:uri)
    
    @notifier.build_finished build
  end

end
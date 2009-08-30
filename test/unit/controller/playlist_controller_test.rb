require File.expand_path(File.dirname(__FILE__) + "/../unit_test_helper")

unit_tests do
  
  test "add_random creates a random PlaylistEntry and redirects to playlist_url" do
    controller = PlaylistController.new
    controller.stubs(:params).returns({})
    PlaylistEntry.expects(:create_random!)
    controller.expects(:playlist_url).returns(:some_url)
    controller.expects(:redirect_to).with(:some_url)

    controller.add_random
  end
  
  test "add_for creates a random PlaylistEntry for the user and redirects to playlist_url" do
    controller = PlaylistController.new
    controller.stubs(:params).returns(:name => :some_user)
    PlaylistEntry.expects(:create_random!).with(:user => :some_user)
    controller.expects(:playlist_url).returns(:some_url)
    controller.expects(:redirect_to).with(:some_url)

    controller.add_for
  end
  
  test "toggle_continuous_play toggles continuous play on PlayerStatus and renders nothing" do
    PlayerStatus.expects(:toggle_continuous_play)
    controller = PlaylistController.new
    controller.expects(:render).with(:nothing => true)
    
    controller.toggle_continuous_play
  end

end
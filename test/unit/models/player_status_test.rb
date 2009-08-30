require File.expand_path(File.dirname(__FILE__) + "/../unit_test_helper")

unit_tests do

  test "jukebox returns the first PlayerStatus" do
    PlayerStatus.expects(:find).with(:first).returns(:some_player_status)
    
    assert_equal :some_player_status, PlayerStatus.jukebox
  end
  
  test "jukebox creates and returns a new PlayerStatus when when one does not already exist" do
    PlayerStatus.expects(:find).with(:first).returns(nil)
    PlayerStatus.expects(:create!).returns(:new_player_status)
    
    assert_equal :new_player_status, PlayerStatus.jukebox
  end
  
  test "playing? returns true when jukebox.status == PLAY" do
    PlayerStatus.stubs(:jukebox).returns(stub(:status => PlayerStatus::PLAY))
    
    assert_true PlayerStatus.playing?
  end

  test "playing? returns false when jukebox.status == PAUSE" do
    PlayerStatus.stubs(:jukebox).returns(stub(:status => PlayerStatus::PAUSE))
    
    assert_false PlayerStatus.playing?
  end

  test "paused? returns true when jukebox.status == PAUSE" do
    PlayerStatus.stubs(:jukebox).returns(stub(:status => PlayerStatus::PAUSE))
    
    assert_true PlayerStatus.paused?
  end

  test "paused? returns false when jukebox.status == PLAY" do
    PlayerStatus.stubs(:jukebox).returns(stub(:status => PlayerStatus::PLAY))
    
    assert_false PlayerStatus.paused?
  end
  
  test "play updates jukebox to status PLAY" do
    PlayerStatus.stubs(:jukebox).returns(jukebox = stub)
    jukebox.expects(:update_attributes!).with(:status => PlayerStatus::PLAY)
    
    PlayerStatus.play
  end
  
  test "pause updates jukebox to status PAUSE" do
    PlayerStatus.stubs(:jukebox).returns(jukebox = stub)
    jukebox.expects(:update_attributes!).with(:status => PlayerStatus::PAUSE)
    
    PlayerStatus.pause
  end

  test "continuous_play? returns true when jukebox.continuous_play? is true" do
    PlayerStatus.stubs(:jukebox).returns(jukebox = stub(:continuous_play? => true))

    assert_true PlayerStatus.continuous_play?
  end
  
  test "continuous_play? returns false when jukebox.continuous_play? is false" do
    PlayerStatus.stubs(:jukebox).returns(jukebox = stub(:continuous_play? => false))

    assert_false PlayerStatus.continuous_play?
  end
  
  test "toggle_continuous_play sets continuous play to true when false" do
    PlayerStatus.stubs(:jukebox).returns(jukebox = stub)
    jukebox.stubs(:continuous_play).returns(false)
    jukebox.expects(:update_attributes!).with(:continuous_play => true)
    
    PlayerStatus.toggle_continuous_play
  end

  test "toggle_continuous_play sets continuous play to false when true" do
    PlayerStatus.stubs(:jukebox).returns(jukebox = stub)
    jukebox.stubs(:continuous_play).returns(true)
    jukebox.expects(:update_attributes!).with(:continuous_play => false)
    
    PlayerStatus.toggle_continuous_play
  end

end
require File.expand_path(File.dirname(__FILE__) + "/../unit_test_helper")

unit_tests do
  test "run loops and performs next operation when there is work to do" do
    player = Player.new(nil, nil)
    player.stubs(:loop).yields
    player.expects(:perform_next_operation).returns(true)
    player.expects(:rest).never
    player.run
  end  

  test "run loops and rests when there is no work to do" do
    player = Player.new(nil, nil)
    player.stubs(:loop).yields
    player.expects(:perform_next_operation).returns(false)
    player.expects(:rest)
    player.run
  end  

  test "player handles state change and returns non-false when state needs to change" do
    player = Player.new(nil, nil)
    player.expects(:send).with('handle_state_change').returns(true)
    player.expects(:send).with('handle_hammertime').never
    player.expects(:send).with('handle_playlist').never

    assert_non_false player.perform_next_operation
  end
  
  test "player handles hammertime and returns non-false when no state change" do
    player = Player.new(nil, nil)
    player.expects(:send).with('handle_state_change').returns(nil)
    player.expects(:send).with('handle_hammertime').returns(true)
    player.expects(:send).with('handle_playlist').never

    assert_non_false player.perform_next_operation
  end
  
  test "player handles playlist and returns non-false when no state change or hammertime" do
    player = Player.new(nil, nil)
    player.expects(:send).with('handle_state_change').returns(nil)
    player.expects(:send).with('handle_hammertime').returns(nil)
    player.expects(:send).with('handle_playlist').returns(true)

    assert_non_false player.perform_next_operation
  end
  
  test "player does nothing and returns non-true when nothing to do" do
    player = Player.new(nil, nil)
    player.expects(:send).with('handle_state_change').returns(nil)
    player.expects(:send).with('handle_hammertime').returns(nil)
    player.expects(:send).with('handle_playlist').returns(nil)

    assert_non_true player.perform_next_operation
  end
  
  test "handle_state_change returns non-true when state hasn't changed" do
    playlist_manager = stub(:state => :some_state)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@state, :some_state)
    assert_non_true player.handle_state_change
  end
  
  test "handle_state_change when switching to play with a paused hammertime, changes the state, resumes the hammertime, and returns true" do
    playlist_manager = stub(:state => Player::PLAYING)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@state, Player::PAUSED)
    player.instance_variable_set(:@hammertime, mock(:play => true))
    
    assert_true player.handle_state_change
    assert_equal Player::PLAYING, player.instance_variable_get(:@state)
  end
  
  test "handle_state_change when switching to play with no hammertime and a paused playlist entry, changes the state, resumes the playlist entry, and returns true" do
    playlist_manager = stub(:state => Player::PLAYING)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@state, Player::PAUSED)
    player.instance_variable_set(:@hammertime, nil)
    player.instance_variable_set(:@playlist_entry, mock(:play => true))
    
    assert_true player.handle_state_change
    assert_equal Player::PLAYING, player.instance_variable_get(:@state)
  end
  
  test "handle_state_change when switching to pause with no hammertime or playlist entry changes the state and returns true" do
    playlist_manager = stub(:state => Player::PAUSED)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@hammertime, nil)
    player.instance_variable_set(:@playlist_entry, nil)
    
    assert_true player.handle_state_change
    assert_equal Player::PAUSED, player.instance_variable_get(:@state)
  end
  
  test "handle_state_change when switching to pause with a hammertime but no playlist entry changes the state and returns true" do
    playlist_manager = stub(:state => Player::PAUSED)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@hammertime, mock(:pause => true))
    player.instance_variable_set(:@playlist_entry, nil)
    
    assert_true player.handle_state_change
    assert_equal Player::PAUSED, player.instance_variable_get(:@state)
  end
  
  test "handle_state_change when switching to pause with a playlist entry but no hammertime changes the state and returns true" do
    playlist_manager = stub(:state => Player::PAUSED)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@hammertime, nil)
    player.instance_variable_set(:@playlist_entry, mock(:pause => true))
    
    assert_true player.handle_state_change
    assert_equal Player::PAUSED, player.instance_variable_get(:@state)
  end
  
  test "handle_state_change when switching to pause changes the state, pauses the hammertime and the playlist entry, and returns true" do
    playlist_manager = stub(:state => Player::PAUSED)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@hammertime, mock(:pause => true))
    player.instance_variable_set(:@playlist_entry, mock(:pause => true))
    
    assert_true player.handle_state_change
    assert_equal Player::PAUSED, player.instance_variable_get(:@state)
  end

  test "handle_hammertime stops the current hammertime and returns non-false" do
    player = Player.new(nil, nil)
    player.expects(:stop_hammertime).returns(true)
    assert_non_false player.handle_hammertime
  end
  
  test "handle_hammertime plays the existing or next hammertime when it is not time to stop and returns non-false" do
    player = Player.new(nil, nil)
    player.expects(:stop_hammertime).returns(false)
    player.expects(:play_hammertime).returns(true)
    assert_non_false player.handle_hammertime
  end
  
  test "handle_hammertime does nothing when there is no hammertime and returns non-true" do
    player = Player.new(nil, nil)
    player.expects(:stop_hammertime).returns(false)
    player.expects(:play_hammertime).returns(false)
    assert_non_true player.handle_hammertime
  end
  
  test "handle_playlist skips the current playlist entry and returns non-false" do
    player = Player.new(nil, nil)
    player.expects(:skip_playlist_entry).returns(true)
    assert_non_false player.handle_playlist
  end
  
  test "handle_playlist plays the existing or next playlist entry when it is not skipped and returns non-false" do
    player = Player.new(nil, nil)
    player.expects(:skip_playlist_entry).returns(false)
    player.expects(:play_playlist_entry).returns(true)
    assert_non_false player.handle_playlist
  end
  
  test "handle_playlist does nothing when there is no playlist entry and returns non-true" do
    player = Player.new(nil, nil)
    player.expects(:skip_playlist_entry).returns(false)
    player.expects(:play_playlist_entry).returns(false)
    assert_non_true player.handle_playlist
  end

  test "stop_hammertime returns non-true when there is no hammertime" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@hammertime, nil)
    assert_non_true player.stop_hammertime
  end
  
  test "stop_hammertime returns non-true when the current hammertime has not passed the end time" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@hammertime, stub(:passed_end_time? => false))
    assert_non_true player.stop_hammertime
  end
  
  test "stop_hammertime stops the hammertime and resumes the playlist entry when hammertime has passed the end time" do
    hammertime = stub(:passed_end_time? => true, :pause_after? => false)
    hammertime.expects(:stop)
    player = Player.new(nil, nil)
    player.instance_variable_set(:@hammertime, hammertime)
    player.instance_variable_set(:@playlist_entry, mock(:play => true))
    assert_non_false player.stop_hammertime
    assert_nil player.instance_variable_get(:@hammertime)
  end

  test "play_hammertime returns non-true when paused" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@state, Player::PAUSED)
    assert_non_true player.play_hammertime
  end
  
  test "play_hammertime returns true when the hammertime is already playing" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@hammertime, stub(:playing? => true))
    assert_true player.play_hammertime
  end
  
  test "play_hammertime pauses the playlist entry and plays the next hammertime" do
    playlist_manager = stub(:next_hammertime => :some_attributes)
    track_class = stub(:new => mock(:play => true))
    player = Player.new(playlist_manager, track_class)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@hammertime, nil)
    player.instance_variable_set(:@playlist_entry, mock(:pause => true))
    assert_non_false player.play_hammertime
  end

  test "skip_playlist_entry returns non-true when there is no playlist entry" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@playlist_entry, nil)
    assert_non_true player.skip_playlist_entry
  end
  
  test "skip_playlist_entry returns non-true when the playlist entry isn't playing" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@playlist_entry, stub(:playing? => false))
    assert_non_true player.skip_playlist_entry
  end
  
  test "skip_playlist_entry returns non-true when the playlist entry is playing but not marked as skip" do
    playlist_manager = stub(:skip? => false)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@playlist_entry, stub(:playing? => true))
    assert_non_true player.skip_playlist_entry
  end
  
  test "skip_playlist_entry stops the playlist entry, nils it, and returns true when the playlist entry is playing and marked as skip" do
    playlist_manager = stub(:skip? => true)
    playlist_entry = stub(:playing? => true)
    playlist_entry.expects(:stop)
    player = Player.new(playlist_manager, nil)
    player.instance_variable_set(:@playlist_entry, playlist_entry)
    assert_true player.skip_playlist_entry
    assert_nil player.instance_variable_get(:@playlist_entry)
  end
  
  test "play_playlist_entry returns non-true if we are paused" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@state, Player::PAUSED)
    assert_non_true player.play_playlist_entry
  end
  
  test "play_playlist_entry returns true if the current playlist entry is playing" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@playlist_entry, stub(:playing? => true))
    assert_true player.play_playlist_entry
  end
  
  test "play_playlist_entry plays the next playlist entry" do
    playlist_manager = stub(:next_playlist_entry => :some_attributes)
    track_class = stub(:new => mock(:play => true))
    player = Player.new(playlist_manager, track_class)
    player.instance_variable_set(:@state, Player::PLAYING)
    player.instance_variable_set(:@playlist_entry, nil)
    assert_non_false player.play_playlist_entry
  end

  test "rest sleeps for SLEEP_DURATION" do
    player = Player.new(nil, nil)
    player.expects(:sleep).with(Player::SLEEP_DURATION)
    player.rest
  end

  test "playing? returns false when state is paused" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@state, Player::PAUSED)
    assert_false player.playing?
  end
  
  test "playing? returns true when state is playing" do
    player = Player.new(nil, nil)
    player.instance_variable_set(:@state, Player::PLAYING)
    assert_true player.playing?
  end

  test "play returns non-true if track is nil" do
    player = Player.new(nil, nil)
    assert_non_true player.play(nil)
  end
  
  test "play calls play on track" do
    player = Player.new(nil, nil)
    track = mock(:play => true)
    assert_non_false player.play(track)
  end
  
  test "pause returns non-true if track is nil" do
    player = Player.new(nil, nil)
    assert_non_true player.pause(nil)
  end
  
  test "pause calls pause on track" do
    player = Player.new(nil, nil)
    track = mock(:pause => true)
    assert_non_false player.pause(track)
  end

  test "next_playlist_entry returns non-true when no next entry" do
    playlist_manager = stub(:next_playlist_entry => nil)
    player = Player.new(playlist_manager, nil)
    assert_non_true player.next_playlist_entry
  end
  
  test "next_playlist_entry sets playlist_entry and returns it" do
    playlist_manager = stub(:next_playlist_entry => :some_attributes)
    track_class = stub
    track_class.expects(:new).with(:some_attributes).returns(:next_entry)
    player = Player.new(playlist_manager, track_class)
    assert_equal :next_entry, player.next_playlist_entry
    assert_equal :next_entry, player.instance_variable_get(:@playlist_entry)
  end
  
  test "next_hammertime returns non-true when no next entry" do
    playlist_manager = stub(:next_hammertime => nil)
    player = Player.new(playlist_manager, nil)
    assert_non_true player.next_hammertime
  end
  
  test "next_hammertime sets hammertime and returns it" do
    playlist_manager = stub(:next_hammertime => :some_attributes)
    track_class = stub
    track_class.expects(:new).with(:some_attributes).returns(:next_entry)
    player = Player.new(playlist_manager, track_class)
    assert_equal :next_entry, player.next_hammertime
    assert_equal :next_entry, player.instance_variable_get(:@hammertime)
  end
end

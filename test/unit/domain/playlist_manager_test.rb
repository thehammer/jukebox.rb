require File.expand_path(File.dirname(__FILE__) + "/../unit_test_helper")

unit_tests do
  test "state returns paused when PlayerState is not playing" do
    PlayerStatus.stubs(:playing?).returns(false)
    assert_equal "paused", PlaylistManager.new.state
  end

  test "state returns playing when PlayerState is playing" do
    PlayerStatus.stubs(:playing?).returns(true)
    assert_equal "playing", PlaylistManager.new.state
  end
  
  test "playing_track returns the track currently marked as playing" do
    PlaylistEntry.stubs(:find_by_status).with(PlaylistEntry::PLAYING).returns(:some_track)
    assert_equal :some_track, PlaylistManager.new.playing_track
  end
  
  test "skip? returns non-true when no track is playing" do
    PlaylistEntry.stubs(:find_by_status).with(PlaylistEntry::PLAYING).returns(nil)
    assert_non_true PlaylistManager.new.skip?
  end
  
  test "skip? returns non-true when track is playing and not marked for skip" do
    PlaylistEntry.stubs(:find_by_status).with(PlaylistEntry::PLAYING).returns(stub(:skip? => false))
    assert_non_true PlaylistManager.new.skip?
  end
  
  test "skip? returns true when track is playing and marked for skip" do
    PlaylistEntry.stubs(:find_by_status).with(PlaylistEntry::PLAYING).returns(stub(:skip? => true))
    assert_true PlaylistManager.new.skip?
  end
  
  test "pause changes PlayerStatus to pause" do
    PlayerStatus.expects(:pause)
    PlaylistManager.new.pause
  end

  test "next_playlist_entry removes all entries marked as playing" do
    PlaylistEntry.expects(:find_all_by_status).with(PlaylistEntry::PLAYING).returns([:playing_1, :playing_2])
    PlaylistEntry.expects(:delete).with(:playing_1)
    PlaylistEntry.expects(:delete).with(:playing_2)
    PlaylistEntry.stubs(:find_next_track_to_play)
    PlaylistManager.new.next_playlist_entry
  end
  
  test "next_playlist_entry returns nil when there are no tracks to play" do
    PlaylistEntry.stubs(:find_all_by_status).with(PlaylistEntry::PLAYING).returns([])
    PlaylistEntry.stubs(:find_next_track_to_play).returns(nil)
    assert_nil PlaylistManager.new.next_playlist_entry
  end
  
  test "next_playlist_entry updates entry status to playing and returns its attributes" do
    PlaylistEntry.stubs(:find_all_by_status).with(PlaylistEntry::PLAYING).returns([])
    next_track = stub(:attributes => :some_attributes)
    next_track.expects(:update_attributes!).with(:status => PlaylistEntry::PLAYING)
    PlaylistEntry.stubs(:find_next_track_to_play).returns(next_track)
    assert_equal :some_attributes, PlaylistManager.new.next_playlist_entry
  end

  test "next_hammertime returns nil when there are no hammertimes in the queue" do
    Hammertime.stubs(:find).with(:first).returns(nil)
    assert_nil PlaylistManager.new.next_hammertime
  end
  
  test "next_hammertime removes a hammertime from the queue and returns its snippet attributes and the after" do
    snippet = stub(:attributes => {:a => 1, :b => 2})
    hammertime = stub(:snippet => snippet, :after => 'pause')
    Hammertime.stubs(:find).with(:first).returns(hammertime)
    Hammertime.expects(:delete).with(hammertime)
    assert_equal({:a => 1, :b => 2, :after => 'pause'}, PlaylistManager.new.next_hammertime)
  end
end

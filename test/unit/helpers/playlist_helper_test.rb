require File.expand_path(File.dirname(__FILE__) + "/../unit_test_helper")

class PlaylistHelperTest < Test::Unit::TestCase

  def test_now_playing_returns_playlist_entry_now_playing
    PlaylistEntry.expects(:find_by_status).with(PlaylistEntry::PLAYING).returns(:now_playing)
    assert_equal :now_playing, class_for(:playlist_helper).new.now_playing
  end
  
  def test_next_returns_playlist_entries_ready_to_play
    PlaylistEntry.expects(:find_all_ready_to_play).returns(:ready_to_play)
    assert_equal :ready_to_play, class_for(:playlist_helper).new.ready_to_play
  end

end
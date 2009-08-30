require File.expand_path(File.dirname(__FILE__) + "/../functional_test_helper")

class PlaylistEntryTest < Test::Unit::TestCase

  def test_find_entries_ready_to_play
    PlaylistEntry.create! :file_location => 'first', :status => PlaylistEntry::UNPLAYED
    PlaylistEntry.create! :file_location => 'second', :status => PlaylistEntry::UNPLAYED
    
    assert_equal 'first', PlaylistEntry.find_all_ready_to_play.first.file_location
  end

  def test_skip
    entry = PlaylistEntry.create! :file_location => 'first', :status => PlaylistEntry::PLAYING
    PlaylistEntry.skip entry.id
    assert_true entry.reload.skip?
  end
  
end
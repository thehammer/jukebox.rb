require File.expand_path(File.dirname(__FILE__) + "/../unit_test_helper")

unit_tests do
  
  test "find_next_track_to_play returns first unplayed track" do
    PlaylistEntry.expects(:find).with(:first, :conditions => {:status => PlaylistEntry::UNPLAYED}, :order => :id).returns(:some_track)

    assert_equal :some_track, PlaylistEntry.find_next_track_to_play
  end
  
  test "find_next_track_to_play returns false when there are no tracks to play and continuous_play is off" do
    PlaylistEntry.stubs(:find).returns(nil)
    PlayerStatus.stubs(:continuous_play?).returns(false)

    assert_false PlaylistEntry.find_next_track_to_play
  end

  test "find_next_track_to_play returns a new random track when there are no tracks to play and continuous_play is on" do
    PlaylistEntry.expects(:find).with(:first, :conditions => {:status => PlaylistEntry::UNPLAYED}, :order => :id).times(2).returns(nil).then.returns(:new_track)
    PlayerStatus.stubs(:continuous_play?).returns(true)
    PlaylistEntry.expects(:create_random!)
    
    assert_equal :new_track, PlaylistEntry.find_next_track_to_play
  end

  test "create_random! creates a new PlaylistEntry randomly" do
    mp3_files = [nil, nil, :some_file_location, nil]
    Dir.expects(:glob).with(File.join(JUKEBOX_MUSIC_ROOT, "**", "*.mp3")).returns(mp3_files)
    PlaylistEntry.expects(:rand).with(mp3_files.size).returns(2)
    PlaylistEntry.expects(:create!).with(:file_location => :some_file_location)
    
    PlaylistEntry.create_random!
  end

  test "create_random! creates a new PlaylistEntry randomly from the users directory" do
    mp3_files = [nil, nil, :some_file_location, nil]
    Dir.expects(:glob).with(File.join(JUKEBOX_MUSIC_ROOT, "some_user", "**", "*.mp3")).returns(mp3_files)
    PlaylistEntry.expects(:rand).with(mp3_files.size).returns(2)
    PlaylistEntry.expects(:create!).with(:file_location => :some_file_location)
    
    PlaylistEntry.create_random!(:user => "some_user")
  end

  test "find_all_ready_to_play returns all unplayed tracks in playlist order" do
    PlaylistEntry.expects(:find).with(:all, :conditions => {:status => PlaylistEntry::UNPLAYED}, :order => :id)
    
    PlaylistEntry.find_all_ready_to_play
  end
  
  test "filename returns filename portion of file_locaiton" do
    entry = PlaylistEntry.new
    entry.file_location = "/tmp/some_song.mp3"
    
    assert_equal "some_song.mp3", entry.filename
  end

  test "id3 constructs a new ID3 AudioFile object from the mp3 file" do
    entry = PlaylistEntry.new
    entry.file_location = :some_location
    ID3::AudioFile.expects(:new).with(:some_location).returns(:some_id3)
    
    assert_equal :some_id3, entry.id3
  end
  
  test "id3 caches the ID3 AudioFile object" do
    entry = PlaylistEntry.new
    entry.file_location = :some_location
    ID3::AudioFile.expects(:new).once.returns(:some_id3)
    
    2.times { assert_equal :some_id3, entry.id3 }
  end
  
  test "title returns title from id3 tag" do
    id3_stub = stub(:tagID3v2 => {'TITLE' => {'text' => :some_title}})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_equal :some_title, entry.title
  end
  
  test "title returns nil when no title exists" do
    id3_stub = stub(:tagID3v2 => {'TITLE' => nil})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_nil entry.title
  end
  
  test "artist returns artist from id3 tag" do
    id3_stub = stub(:tagID3v2 => {'ARTIST' => {'text' => :some_artist}})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_equal :some_artist, entry.artist
  end
  
  test "artist returns nil when no artist exists" do
    id3_stub = stub(:tagID3v2 => {'ARTIST' => nil})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_nil entry.artist
  end
  
  test "album returns album from id3 tag" do
    id3_stub = stub(:tagID3v2 => {'ALBUM' => {'text' => :some_album}})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_equal :some_album, entry.album
  end
  
  test "album returns nil when no album exists" do
    id3_stub = stub(:tagID3v2 => {'ALBUM' => nil})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_nil entry.album
  end
  
  test "track_number returns tracknum from id3 tag" do
    id3_stub = stub(:tagID3v2 => {'TRACKNUM' => {'text' => :some_track_number}})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_equal :some_track_number, entry.track_number
  end
  
  test "track_number returns nil when no tracknum exists" do
    id3_stub = stub(:tagID3v2 => {'TRACKNUM' => nil})
    entry = PlaylistEntry.new
    entry.stubs(:id3).returns(id3_stub)
    
    assert_nil entry.track_number
  end
  
  test "to_s composes artist, title, and album" do
    entry = PlaylistEntry.new
    entry.stubs(:artist).returns("Some Artist")
    entry.stubs(:title).returns("Some Title")
    entry.stubs(:album).returns("Some Album")
    
    assert_equal "Some Artist - Some Title (Some Album)", entry.to_s
  end
  
end
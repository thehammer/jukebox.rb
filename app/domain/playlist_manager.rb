class PlaylistManager
  PAUSED = 'paused'
  PLAYING = 'playing'
  
  def state
    PlayerStatus.playing? ? PLAYING : PAUSED
  end
  
  def playing_track
    PlaylistEntry.find_by_status(PlaylistEntry::PLAYING)
  end
    
  def skip?
    playing_track and playing_track.skip?
  end

  def pause
    PlayerStatus.pause
  end

  def next_playlist_entry
    PlaylistEntry.find_all_by_status(PlaylistEntry::PLAYING).each { |p| PlaylistEntry.delete(p) }
    return unless entry = PlaylistEntry.find_next_track_to_play
    entry.update_attributes!(:status => PlaylistEntry::PLAYING)
    entry.attributes
  end

  def next_hammertime
    return unless hammertime = Hammertime.find(:first)
    attributes = hammertime.snippet.attributes.merge(:after => hammertime.after)
    Hammertime.delete(hammertime)
    attributes
  end
end

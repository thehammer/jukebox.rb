module PlaylistHelper
  def now_playing
    PlaylistEntry.find_by_status(PlaylistEntry::PLAYING)
  end
  
  def ready_to_play
    PlaylistEntry.find_all_ready_to_play
  end
  
  def playing?
    PlayerStatus.playing?
  end
  
  def continuous_play?
    PlayerStatus.continuous_play?
  end
end
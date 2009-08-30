class PlayerStatus < ActiveRecord::Base
  PLAY = "play"
  PAUSE = "pause"
  
  def self.jukebox
    find(:first) or create!
  end
  
  def self.playing?
    return jukebox.status == PLAY
  end
  
  def self.paused?
    return jukebox.status == PAUSE
  end
  
  def self.play
    jukebox.update_attributes! :status => PLAY
  end
  
  def self.pause
    jukebox.update_attributes! :status => PAUSE
  end
  
  def self.continuous_play?
    jukebox.continuous_play?
  end
  
  def self.toggle_continuous_play
    jukebox.update_attributes! :continuous_play => (jukebox.continuous_play == false)
  end
  
end
class Player
  SLEEP_DURATION = 1
  PAUSED = 'paused'
  PLAYING = 'playing'
  
  OPERATIONS = %w{
    handle_state_change
    handle_hammertime
    handle_playlist
  }
  
  def initialize(playlist_manager, track_class)
    @playlist_manager = playlist_manager
    @track_class = track_class
  end
  
  def run
    loop do
      perform_next_operation or rest
    end
  end

  def perform_next_operation
    OPERATIONS.detect { |action| send action }
  end
  
  def handle_state_change
    return if @state == @playlist_manager.state
    
    @state = @playlist_manager.state
    
    if playing?
      play @hammertime or play @playlist_entry
    else
      pause @hammertime
      pause @playlist_entry
    end
    
    true
  end

  def handle_hammertime
    stop_hammertime or play_hammertime
  end

  def handle_playlist
    skip_playlist_entry or play_playlist_entry
  end
  
  def stop_hammertime
    return unless @hammertime && @hammertime.passed_end_time?
    @playlist_manager.pause if @hammertime.pause_after?
    @hammertime.stop
    @hammertime = nil
    play @playlist_entry
  end
  
  def play_hammertime
    return unless playing?
    return true if @hammertime && @hammertime.playing?
    if next_hammertime
      pause @playlist_entry
      play @hammertime
    end
  end
  
  def skip_playlist_entry
    return unless @playlist_entry && @playlist_entry.playing? && @playlist_manager.skip?
    @playlist_entry.stop
    @playlist_entry = nil
    true
  end
  
  def play_playlist_entry
    return unless playing?
    return true if @playlist_entry && @playlist_entry.playing?
    play next_playlist_entry
  end

  def rest
    sleep SLEEP_DURATION
  end

  def playing?
    @state == PLAYING
  end
  
  def play track
    return unless track
    track.play
  end
  
  def pause track
    return unless track
    track.pause
  end
  
  def next_playlist_entry
    return unless track_attributes = @playlist_manager.next_playlist_entry
    @playlist_entry = @track_class.new track_attributes
  end

  def next_hammertime
    return unless track_attributes = @playlist_manager.next_hammertime
    @hammertime = @track_class.new track_attributes
  end
end

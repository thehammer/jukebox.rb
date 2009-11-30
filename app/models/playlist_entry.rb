require 'id3'

class PlaylistEntry < ActiveRecord::Base
  UNPLAYED = "unplayed"
  PLAYING = "playing"

  def self.playing_track
    find_by_status(PlaylistEntry::PLAYING)
  end
  
  def self.find_ready_to_play
    find(:first, :conditions => {:status => UNPLAYED}, :order => :id)
  end

  def self.find_all_ready_to_play
    find(:all, :conditions => {:status => UNPLAYED}, :order => :id)
  end

  def self.find_next_track_to_play
    track = find_ready_to_play
    return track unless track.nil?
    return false unless PlayerStatus.continuous_play?
    create_random!
    find_ready_to_play
  end

  def self.create_random!(params = {})
    mp3_files = Dir.glob(File.join([JUKEBOX_MUSIC_ROOT, params[:user], "**", "*.mp3"].compact))
    return if mp3_files.empty?

    srand(Time.now.to_i)
    (params[:number_to_create] || 1).to_i.times do
      create! :file_location => mp3_files[rand(mp3_files.size)]
    end
  end

  def self.skip(track_id)
    find(track_id).update_attributes! :skip => true
  end
    
  def filename
    self.file_location.split('/').last
  end
  
  begin # ID3 Tag Methods
    def id3
      @id3 ||= ID3::AudioFile.new(file_location)
    end
  
    def title
      id3.tagID3v2['TITLE']['text'] if id3.tagID3v2 && id3.tagID3v2['TITLE']
    end

    def artist
      id3.tagID3v2['ARTIST']['text'] if id3.tagID3v2 && id3.tagID3v2['ARTIST']
    end

    def album
      id3.tagID3v2['ALBUM']['text'] if id3.tagID3v2 && id3.tagID3v2['ALBUM']
    end

    def track_number
      id3.tagID3v2['TRACKNUM']['text'] if id3.tagID3v2 && id3.tagID3v2['TRACKNUM']
    end
  
    def to_s
      "#{artist} - #{title} (#{album})"
    end
  end
  
end

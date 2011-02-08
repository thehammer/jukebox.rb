require 'tagfile/tagfile'

class PlaylistEntry < ActiveRecord::Base
  UNPLAYED = "unplayed"
  PLAYING = "playing"

  SUPPORTED_FORMATS = %w[
    mp3
    m4a
  ]

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
    users = params[:user] ? [params[:user]] : User.find_all_by_active(true).map(&:username)
    filemask = File.join([JUKEBOX_MUSIC_ROOT, "{#{users.join(",")}}", "**", "*.{#{SUPPORTED_FORMATS.join(",")}}"].compact)
    mp3_files = Dir[filemask]
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

  def contributor
    file_location.sub(JUKEBOX_MUSIC_ROOT, "").split('/')[1].titlecase
  end

  def gravatar(size = nil)
    User.gravatar_for(contributor, size = nil)
  end

  begin # ID3 Tag Methods
    def id3
      @id3 ||= TagFile::File.new(file_location)
    end

    def title
      id3.title
    end

    def artist
      id3.artist
    end

    def album
      id3.album
    end

    def track_number
      id3.track
    end

    def to_s
      "#{artist} - <span style='font-style: italic; vertical-align: top'>#{title}</span>"
    end
  end

end

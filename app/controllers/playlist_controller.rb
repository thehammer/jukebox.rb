require 'find'

class PlaylistController < ApplicationController

  def add_random
    PlaylistEntry.create_random!(:number_to_create => params[:number_to_create] || 1)

    redirect_to playlist_url
  end

  def add_track
    PlaylistEntry.create! :file_location => File.join(JUKEBOX_MUSIC_ROOT, params[:filepath])

    redirect_to playlist_url
  end

  def add_for
    PlaylistEntry.create_random!(:user => params[:name])

    redirect_to playlist_url
  end

  def browse
  end

  def delete
    PlaylistEntry.create_random!(:user => PlaylistEntry.find(params[:id]).contributor.downcase)
    PlaylistEntry.delete_all(["id = ? and status = ?", params[:id], PlaylistEntry::UNPLAYED])

    redirect_to playlist_url
  end

  def index
    @volume = %x[/usr/bin/osascript -e 'set currentVolume to output volume of (get volume settings)'].chomp
  end

  def pause
    PlayerStatus.pause

    redirect_to playlist_url
  end

  def play
    PlayerStatus.play

    redirect_to playlist_url
  end

  def search
  end

  def skip
    PlaylistEntry.create_random!(:user => PlaylistEntry.find(params[:id]).contributor.downcase)
    PlaylistEntry.skip(params[:id])

    redirect_to playlist_url
  end

  def status
    render :text => PlayerStatus.status
  end

  def skip_requested
    current_track = PlaylistEntry.playing_track
    skip = current_track.nil? ? false : current_track.skip

    render :text => skip.to_s
  end

  def volume_down
    %x[/usr/bin/osascript -e 'set volume output volume (output volume of (get volume settings) - 5)']
    redirect_to playlist_url
  end

  def volume_up
    %x[/usr/bin/osascript -e 'set volume output volume (output volume of (get volume settings) + 5)']
    redirect_to playlist_url
  end

  def next_entry
    PlaylistEntry.find_all_by_status(PlaylistEntry::PLAYING).each { |p| PlaylistEntry.delete(p) }
    filename = ""
    if entry = PlaylistEntry.find_next_track_to_play
      entry.update_attributes!(:status => PlaylistEntry::PLAYING)
      filename = entry.file_location
    end

    render :text => filename
  end

  def next_hammertime
    text = ""
    if hammertime = Hammertime.find(:first)
      text = [hammertime.snippet.file_location,
              hammertime.snippet.start_time,
              hammertime.snippet.end_time,
              hammertime.after].join('|')
      Hammertime.delete(hammertime)
    end

    render :text => text
  end

  def toggle_continuous_play
    PlayerStatus.toggle_continuous_play

    render :nothing => true
  end

end

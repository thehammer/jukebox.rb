require 'find'

class PlaylistController < ApplicationController

  def add_random
    PlaylistEntry.create_random!(:number_to_create => params[:number_to_create] || 1)
    
    redirect_to playlist_url
  end
  
  def add_for
    PlaylistEntry.create_random!(:user => params[:name])
    
    redirect_to playlist_url
  end
  
  def delete
    PlaylistEntry.delete(params[:id])

    redirect_to playlist_url
  end

  def pause
    PlayerStatus.pause

    redirect_to playlist_url
  end

  def play
    PlayerStatus.play

    redirect_to playlist_url
  end
  
  def skip
    PlaylistEntry.skip(params[:id])
    sleep 1
    
    redirect_to playlist_url
  end
  
  def toggle_continuous_play
    PlayerStatus.toggle_continuous_play
    
    render :nothing => true
  end

end

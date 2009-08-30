class HammertimeController < ApplicationController

  def add_for
    after = params[:after] || PlayerStatus::PLAY
    snippet = Snippet.find_by_name(params[:name])
    Hammertime.create!(:snippet => snippet, :after => after) if snippet
    
    redirect_to playlist_url
  end
end
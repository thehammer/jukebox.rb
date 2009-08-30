ActionController::Routing::Routes.draw do |map|
  map.connect '', :controller => 'playlist', :action => 'index'
  map.playlist '/playlist', :controller => 'playlist', :action => 'index'
  map.playlist_add_random_number '/playlist/add_random/:number_to_create', :controller => 'playlist', :action => 'add_random'
  map.playlist_add_random '/playlist/add_random', :controller => 'playlist', :action => 'add_random'
  map.playlist_add_for '/playlist/add_for/:name', :controller => 'playlist', :action => 'add_for'
  map.playlist_delete '/playlist/delete/:id', :controller => 'playlist', :action => 'delete'
  map.playlist_skip '/playlist/skip/:id', :controller => 'playlist', :action => 'skip'
  map.playlist_play '/playlist/play', :controller => 'playlist', :action => 'play'
  map.playlist_pause '/playlist/pause', :controller => 'playlist', :action => 'pause'
  map.playlist_toggle_continuous_play '/playlist/toggle_continuous_play', :controller => 'playlist', :action => 'toggle_continuous_play'
  
  map.hammertime_add_for '/hammertime/add_for/:name', :controller => 'hammertime', :action => 'add_for'
end

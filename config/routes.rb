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
  map.playlist_status '/playlist/status', :controller => 'playlist', :action => 'status'
  map.playlist_skip_requested '/playlist/skip_requested', :controller => 'playlist', :action => 'skip_requested'
  map.playlist_next_entry '/playlist/next_entry', :controller => 'playlist', :action => 'next_entry'
  map.playlist_next_hammertime '/playlist/next_hammertime', :controller => 'playlist', :action => 'next_hammertime'

  map.hammertime_add_for '/hammertime/add_for/:name', :controller => 'hammertime', :action => 'add_for'

  map.user_activate '/user/activate/:username', :controller => 'user', :action => 'activate'
  map.user_inactivate '/user/inactivate/:username', :controller => 'user', :action => 'inactivate'
  map.user_show '/user', :controller => 'user', :action => 'index'

end

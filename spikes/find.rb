ENV['JUKEBOX_MUSIC'] = "/Users/jason/Music"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'find'

Find.find(JUKEBOX_MUSIC_ROOT) do |file|
  puts file if file =~ /\.mp3$/
end
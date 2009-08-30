require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

puts "mp3info"
require 'mp3info'

Mp3Info.open(ARGV[0]) do |mp3|
  puts mp3
  puts "Title: #{mp3.tag2.title}"
  puts "Artist: #{mp3.tag2.artist}"
  puts "Album: #{mp3.tag2.album}"
  puts "Track #: #{mp3.tag2.tracknum}"
end


puts "ID3-v0.4"
require 'id3'

a = ID3::AudioFile.new(ARGV[0])

if a.tagID3v2
  puts "Title: #{a.tagID3v2['TITLE']['text']}"
  puts "Artist: #{a.tagID3v2['ARTIST']['text']}"
  puts "Album: #{a.tagID3v2['ALBUM']['text']}"
  puts "Track #: #{a.tagID3v2['TRACKNUM']['text']}"
end

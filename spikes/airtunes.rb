require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'raop'
require 'icanhasaudio'
require 'id3'

def get_id3_info(filename)
  info = {}

  a = ID3::AudioFile.new(filename)

  if a.tagID3v2
    puts "Has track info!"
    info[:title] = a.tagID3v2['TITLE']['text'] if a.tagID3v2['TITLE']
    info[:artist] = a.tagID3v2['ARTIST']['text'] if a.tagID3v2['ARTIST']
    info[:album] = a.tagID3v2['ALBUM']['text'] if a.tagID3v2['ALBUM']
    info[:tracknum] = a.tagID3v2['TRACKNUM']['text'] if a.tagID3v2['TRACKNUM']
    info[:genre] = a.tagID3v2['CONTENTTYPE']['text'] if a.tagID3v2['CONTENTTYPE']
    info[:length] = a.tagID3v2['SONGLEN']['text'] if a.tagID3v2['SONGLEN']
  end
  
  info
end

rd, wr = IO.pipe

if fork
  # decoder
  rd.close # we don't need this end of the pipe, and must close it

  reader = Audio::MPEG::Decoder.new

  Dir.new(ARGV[0]).each do |filename|
    filename = ARGV[0]+ "/" + filename
    next unless filename =~ /\.mp3$/

    info = get_id3_info(filename)
    begin
      puts "\nNow Playing:"
      puts "Artist: #{info[:artist]}"
      puts "Title: #{info[:title]}"
      puts "Album: #{info[:album]}"
      puts "Track: #{info[:tracknum]}"
      puts "Genre: #{info[:genre]}"
      # puts "Length: #{info[:length]}"
      reader.decode(File.open(filename, 'rb'), wr)
    rescue Errno::ESPIPE
      # Ignore seek error
    ensure
      puts "Done decoding."
    end
  end
  wr.close
  Process.wait
else
  # RAOP streamer
  wr.close # we don't need this end of the pipe, and must close it
  
  sleep 2 # wait for decoding to load up the buffer
  raop = Net::RAOP::Client.new(ARGV[1])
  raop.connect
  raop.volume = 0
  raop.play rd
  raop.disconnect
  rd.close
end

require 'rubygems'
require 'icanhasaudio'

reader = Audio::MPEG::Decoder.new
reader.decode(File.open(ARGV[0], 'rb'), File.open(ARGV[1], 'wb'))
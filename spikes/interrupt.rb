require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'raop'
require 'icanhasaudio'

main = ARGV[0]
interrupt = ARGV[1]
delay = ARGV[2].to_i
ip = ARGV[3]

interrupt_time = delay.seconds.from_now

def decode(filename, writer)
  reader = Audio::MPEG::Decoder.new
  begin
    puts "Decoding #{filename}..."
    reader.decode(File.open(filename, 'r'), writer)
  rescue Errno::ESPIPE
    # Ignore seek error
  ensure
    puts "Done decoding #{filename}."
  end
end

rd, wr = IO.pipe

fork do # source
  rd.close

  mrd, mwr = IO.pipe
  
  fork do # main track
    mrd.close
    
    decode(main, mwr)
    mwr.close
  end
    
  mwr.close

  sleep 2 # wait for decoding to load buffer
  interrupted = false
  while !mrd.eof?
    if !interrupted && Time.now > interrupt_time
      # interrupt with new song
      interrupted = true
      decode(interrupt, wr)
    else
      # play from main song
      wr << mrd.read(4096 * 2 * 2)
    end
  end
  
  wr.close
  mrd.close
  Process.wait
end

wr.close

sleep 2 # wait for decoding to load up the buffer
raop = Net::RAOP::Client.new(ip)
puts "Connecting..."
raop.connect
puts "Connected."
puts "Setting volume..."
raop.volume = 0
puts "Volume set."
puts "Playing..."
raop.play rd
puts "Done."
puts "Disconnecting..."
raop.disconnect
puts "Disconnected."
rd.close

Process.wait
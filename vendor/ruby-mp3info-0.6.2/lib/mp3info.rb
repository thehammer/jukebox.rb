# $Id: mp3info.rb 71 2008-03-02 07:10:26Z moumar $
# License:: Ruby
# Author:: Guillaume Pierronnet (mailto:moumar_AT__rubyforge_DOT_org)
# Website:: http://ruby-mp3info.rubyforge.org/

require "delegate"
require "fileutils"
require "mp3info/extension_modules"
require "mp3info/id3v2"

# ruby -d to display debugging infos

# Raised on any kind of error related to ruby-mp3info
class Mp3InfoError < StandardError ; end

class Mp3InfoInternalError < StandardError #:nodoc:
end

class Mp3Info

  VERSION = "0.6.2"

  LAYER = [ nil, 3, 2, 1]
  BITRATE = [
    [
      [32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448],
      [32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384],
      [32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320] ],
    [
      [32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256],
      [8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160],
      [8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160]
    ]
  ]
  SAMPLERATE = [
    [ 44100, 48000, 32000 ],
    [ 22050, 24000, 16000 ]
  ]
  CHANNEL_MODE = [ "Stereo", "JStereo", "Dual Channel", "Single Channel"]

  GENRES = [
    "Blues", "Classic Rock", "Country", "Dance", "Disco", "Funk",
    "Grunge", "Hip-Hop", "Jazz", "Metal", "New Age", "Oldies",
    "Other", "Pop", "R&B", "Rap", "Reggae", "Rock",
    "Techno", "Industrial", "Alternative", "Ska", "Death Metal", "Pranks",
    "Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz+Funk",
    "Fusion", "Trance", "Classical", "Instrumental", "Acid", "House",
    "Game", "Sound Clip", "Gospel", "Noise", "AlternRock", "Bass",
    "Soul", "Punk", "Space", "Meditative", "Instrumental Pop", "Instrumental Rock",
    "Ethnic", "Gothic", "Darkwave", "Techno-Industrial", "Electronic", "Pop-Folk",
    "Eurodance", "Dream", "Southern Rock", "Comedy", "Cult", "Gangsta",
    "Top 40", "Christian Rap", "Pop/Funk", "Jungle", "Native American", "Cabaret",
    "New Wave", "Psychadelic", "Rave", "Showtunes", "Trailer", "Lo-Fi",
    "Tribal", "Acid Punk", "Acid Jazz", "Polka", "Retro", "Musical",
    "Rock & Roll", "Hard Rock", "Folk", "Folk/Rock", "National Folk", "Swing",
    "Fast-Fusion", "Bebob", "Latin", "Revival", "Celtic", "Bluegrass", "Avantgarde",
    "Gothic Rock", "Progressive Rock", "Psychedelic Rock", "Symphonic Rock", "Slow Rock", "Big Band",
    "Chorus", "Easy Listening", "Acoustic", "Humour", "Speech", "Chanson",
    "Opera", "Chamber Music", "Sonata", "Symphony", "Booty Bass", "Primus",
    "Porn Groove", "Satire", "Slow Jam", "Club", "Tango", "Samba",
    "Folklore", "Ballad", "Power Ballad", "Rhythmic Soul", "Freestyle", "Duet",
    "Punk Rock", "Drum Solo", "A capella", "Euro-House", "Dance Hall",
    "Goa", "Drum & Bass", "Club House", "Hardcore", "Terror",
    "Indie", "BritPop", "NegerPunk", "Polsk Punk", "Beat",
    "Christian Gangsta", "Heavy Metal", "Black Metal", "Crossover", "Contemporary C",
    "Christian Rock", "Merengue", "Salsa", "Thrash Metal", "Anime", "JPop",
    "SynthPop" ]

  TAGSIZE = 128
  #MAX_FRAME_COUNT = 6  #number of frame to read for encoder detection
  V1_V2_TAG_MAPPING = { 
    "title"    => "TIT2",
    "artist"   => "TPE1", 
    "album"    => "TALB",
    "year"     => "TYER",
    "tracknum" => "TRCK",
    "comments" => "COMM",
    "genre_s"  => "TCON"
  }
  
  # http://www.codeproject.com/audio/MPEGAudioInfo.asp
  SAMPLES_PER_FRAME = [
    [384, 384, 384],    # Layer I   
    [1152, 1152, 1152], # Layer II
    [1152, 576, 576]    # Layer III
  ]

  # mpeg version = 1 or 2
  attr_reader(:mpeg_version)

  # layer = 1, 2, or 3
  attr_reader(:layer)

  # bitrate in kbps
  attr_reader(:bitrate)

  # samplerate in Hz
  attr_reader(:samplerate)

  # channel mode => "Stereo", "JStereo", "Dual Channel" or "Single Channel"
  attr_reader(:channel_mode)

  # variable bitrate => true or false
  attr_reader(:vbr)

  # only used in vbr mode
  attr_reader(:samples_per_frame)

  # length in seconds as a Float
  attr_reader(:length)

  # error protection => true or false
  attr_reader(:error_protection)

  #a sort of "universal" tag, regardless of the tag version, 1 or 2, with the same keys as @tag1
  #this tag has priority over @tag1 and @tag2 when writing the tag with #close
  attr_reader(:tag)

  # id3v1 tag as a Hash. You can modify it, it will be written when calling
  # "close" method.
  attr_accessor(:tag1)

  # id3v2 tag attribute as an ID3v2 object. You can modify it, it will be written when calling
  # "close" method.
  attr_accessor(:tag2)

  # the original filename
  attr_reader(:filename)

  # Moved hastag1? and hastag2? to be booleans
  attr_reader(:hastag1, :hastag2)
  
  # Test the presence of an id3v1 tag in file +filename+
  def self.hastag1?(filename)
    File.open(filename) { |f|
      f.seek(-TAGSIZE, File::SEEK_END)
      f.read(3) == "TAG"
    }
  end

  # Test the presence of an id3v2 tag in file +filename+
  def self.hastag2?(filename)
    File.open(filename) { |f|
      f.read(3) == "ID3"
    }
  end


  # Remove id3v1 tag from +filename+
  def self.removetag1(filename)
    if self.hastag1?(filename)
      newsize = File.size(filename) - TAGSIZE
      File.open(filename, "rb+") { |f| f.truncate(newsize) }
    end
  end
  
  # Remove id3v2 tag from +filename+
  def self.removetag2(filename)
    self.open(filename) do |mp3|
      mp3.tag2.clear
    end
  end

  # Instantiate Mp3Info object with name +filename+ and an
  # options hash for ID3v2#new underlying object
  def initialize(filename, id3v2_options = {})
    $stderr.puts("#{self.class}::new() does not take block; use #{self.class}::open() instead") if block_given?
    @filename = filename
    @id3v2_options = id3v2_options
    reload
  end

  # reload (or load for the first time) the file from disk
  def reload
    raise(Mp3InfoError, "empty file") unless File.size?(@filename)
    @hastag1 = false
    
    @tag1 = {}
    @tag1.extend(HashKeys)

    @tag2 = ID3v2.new(@id3v2_options)

    @file = File.new(filename, "rb")
    @file.extend(Mp3FileMethods)
    
    begin
      parse_tags
      @tag1_orig = @tag1.dup

      @tag = {}

      if hastag1?
	@tag = @tag1.dup
      end

      if hastag2?
	@tag = {}
      #creation of a sort of "universal" tag, regardless of the tag version
	V1_V2_TAG_MAPPING.each do |key1, key2| 
	  t2 = @tag2[key2]
	  next unless t2
	  @tag[key1] = t2.is_a?(Array) ? t2.first : t2

	  if key1 == "tracknum"
	    val = @tag2[key2].is_a?(Array) ? @tag2[key2].first : @tag2[key2]
	    @tag[key1] = val.to_i
	  end
	end
      end

      @tag.extend(HashKeys)
      @tag_orig = @tag.dup


      ### extracts MPEG info from MPEG header and stores it in the hash @mpeg
      ###  head (fixnum) = valid 4 byte MPEG header
      
      found = false

      5.times do
	head = find_next_frame() 
	@mpeg_version = [2, 1][head[19]]
	@layer = LAYER[bits(head, 18,17)]
	next if @layer.nil?
	@bitrate = BITRATE[@mpeg_version-1][@layer-1][bits(head, 15,12)-1]
	@error_protection = head[16] == 0 ? true : false
	@samplerate = SAMPLERATE[@mpeg_version-1][bits(head, 11,10)]
	@padding = (head[9] == 1 ? true : false)
	@channel_mode = CHANNEL_MODE[@channel_num = bits(head, 7,6)]
	@copyright = (head[3] == 1 ? true : false)
	@original = (head[2] == 1 ? true : false)
	@vbr = false
	found = true
	break
      end

      raise(Mp3InfoError, "Cannot find good frame") unless found


      seek = @mpeg_version == 1 ? 
	(@channel_num == 3 ? 17 : 32) :       
	(@channel_num == 3 ?  9 : 17)

      @file.seek(seek, IO::SEEK_CUR)
      
      vbr_head = @file.read(4)
      if vbr_head == "Xing"
	puts "Xing header (VBR) detected" if $DEBUG
	flags = @file.get32bits
	@streamsize = @frames = 0
	flags[1] == 1 and @frames = @file.get32bits
	flags[2] == 1 and @streamsize = @file.get32bits 
	puts "#{@frames} frames" if $DEBUG
	raise(Mp3InfoError, "bad VBR header") if @frames.zero?
	# currently this just skips the TOC entries if they're found
	@file.seek(100, IO::SEEK_CUR) if flags[0] == 1
	@vbr_quality = @file.get32bits if flags[3] == 1

        @samples_per_frame = SAMPLES_PER_FRAME[@layer-1][@mpeg_version-1] 
	@length = @frames * @samples_per_frame / Float(@samplerate)

	@bitrate = (((@streamsize/@frames)*@samplerate)/144) >> 10
	@vbr = true
      else
	# for cbr, calculate duration with the given bitrate
	@streamsize = @file.stat.size - (@hastag1 ? TAGSIZE : 0) - (@tag2.valid? ? @tag2.io_position : 0)
	@length = ((@streamsize << 3)/1000.0)/@bitrate
	if @tag2["TLEN"]
	  # but if another duration is given and it isn't close (within 5%)
	  #  assume the mp3 is vbr and go with the given duration
	  tlen = (@tag2["TLEN"].is_a?(Array) ? @tag2["TLEN"].last : @tag2["TLEN"]).to_i/1000
	  percent_diff = ((@length.to_i-tlen)/tlen.to_f)
	  if percent_diff.abs > 0.05
	    # without the xing header, this is the best guess without reading
	    #  every single frame
	    @vbr = true
	    @length = @tag2["TLEN"].to_i/1000
	    @bitrate = (@streamsize / @bitrate) >> 10
	  end
	end
      end
    ensure
      @file.close
    end
  end

  # "block version" of Mp3Info::new()
  def self.open(*params)
    m = self.new(*params)
    ret = nil
    if block_given?
      begin
        ret = yield(m)
      ensure
        m.close
      end
    else
      ret = m
    end
    ret
  end

  # Remove id3v1 from mp3
  def removetag1
    if hastag1?
      Mp3Info.removetag1(@filename)
      @tag1.clear
    end
    self
  end
  
  # Remove id3v2 from mp3
  def removetag2
    @tag2.clear
    self
  end

  # Does the file has an id3v1 or v2 tag?
  def hastag?
    @hastag1 or @tag2.valid?
  end

  # Does the file has an id3v1 tag?
  def hastag1?
    @hastag1
  end

  # Does the file has an id3v2 tag?
  def hastag2?
    @tag2.valid?
  end

  # write to another filename at close()
  def rename(new_filename)
    @filename = new_filename
  end
  
  # Flush pending modifications to tags and close the file
  def close
    puts "close" if $DEBUG
    if @tag != @tag_orig
      puts "@tag has changed" if $DEBUG

      # @tag1 has precedence over @tag
      if @tag1 == @tag1_orig
	@tag.each do |k, v|
	  @tag1[k] = v
	end
      end
      
      V1_V2_TAG_MAPPING.each do |key1, key2|
        @tag2[key2] = @tag[key1] if @tag[key1]
      end
    end

    if @tag1 != @tag1_orig
      puts "@tag1 has changed" if $DEBUG
      raise(Mp3InfoError, "file is not writable") unless File.writable?(@filename)
      #@tag1_orig.update(@tag1)
      @tag1_orig = @tag1.dup
      File.open(@filename, 'rb+') do |file|
	file.seek(-TAGSIZE, File::SEEK_END)
	t = file.read(3)
	if t != 'TAG'
	  #append new tag
	  file.seek(0, File::SEEK_END)
	  file.write('TAG')
	end
	str = [
	  @tag1_orig["title"]||"",
	  @tag1_orig["artist"]||"",
	  @tag1_orig["album"]||"",
	  ((@tag1_orig["year"] != 0) ? ("%04d" % @tag1_orig["year"].to_i) : "\0\0\0\0"),
	  @tag1_orig["comments"]||"",
	  0,
	  @tag1_orig["tracknum"]||0,
	  @tag1_orig["genre"]||255
	  ].pack("Z30Z30Z30Z4Z28CCC")
	file.write(str)
      end
    end

    if @tag2.changed?
      puts "@tag2 has changed" if $DEBUG
      raise(Mp3InfoError, "file is not writable") unless File.writable?(@filename)
      tempfile_name = nil
      File.open(@filename, 'rb+') do |file|
	
	#if tag2 already exists, seek to end of it
	if @tag2.valid?
	  file.seek(@tag2.io_position)
	end
  #      if @file.read(3) == "ID3"
  #        version_maj, version_min, flags = @file.read(3).unpack("CCB4")
  #        unsync, ext_header, experimental, footer = (0..3).collect { |i| flags[i].chr == '1' }
  #	tag2_len = @file.get_syncsafe
  #        @file.seek(@file.get_syncsafe - 4, IO::SEEK_CUR) if ext_header
  #	@file.seek(tag2_len, IO::SEEK_CUR)
  #      end
	tempfile_name = @filename + ".tmp"
	File.open(tempfile_name, "wb") do |tempfile|
	  unless @tag2.empty?
	    tempfile.write(@tag2.to_bin)
	  end

	  bufsiz = file.stat.blksize || 4096
	  while buf = file.read(bufsiz)
	    tempfile.write(buf)
	  end
	end
      end
      File.rename(tempfile_name, @filename)
    end
  end

  # inspect inside Mp3Info
  def to_s
    s = "MPEG #{@mpeg_version} Layer #{@layer} #{@vbr ? "VBR" : "CBR"} #{@bitrate} Kbps #{@channel_mode} #{@samplerate} Hz length #{@length} sec. error protection #{@error_protection} "
    s << "tag1: "+@tag1.inspect+"\n" if @hastag1
    s << "tag2: "+@tag2.inspect+"\n" if @tag2.valid?
    s
  end


private
  
  ### parses the id3 tags of the currently open @file
  def parse_tags
    return if @file.stat.size < TAGSIZE  # file is too small
    @file.seek(0)
    f3 = @file.read(3)
    gettag1 if f3 == "TAG"  # v1 tag at beginning
    begin
      @tag2.from_io(@file) if f3 == "ID3"  # v2 tag at beginning
    rescue RuntimeError => e
      raise(Mp3InfoError, e.message)
    end
      
    unless @hastag1         # v1 tag at end
        # this preserves the file pos if tag2 found, since gettag2 leaves
        #  the file at the best guess as to the first MPEG frame
        pos = (@tag2.valid? ? @file.pos : 0)
        # seek to where id3v1 tag should be
        @file.seek(-TAGSIZE, IO::SEEK_END) 
        gettag1 if @file.read(3) == "TAG"
        @file.seek(pos)
    end
  end

  ### reads in id3 field strings, stripping out non-printable chars
  ###  len (fixnum) = number of chars in field
  ### returns string
  def read_id3_string(len)
    #FIXME handle unicode strings
    #return @file.read(len)
    s = ""
    len.times do
      c = @file.getc
      # only append printable characters
      s << c if c >= 32 and c < 254
    end
    return s.strip
    #return (s[0..2] == "eng" ? s[3..-1] : s)
  end
  
  ### gets id3v1 tag information from @file
  ### assumes @file is pointing to char after "TAG" id
  def gettag1
    @hastag1 = true
    @tag1["title"] = read_id3_string(30)
    @tag1["artist"] = read_id3_string(30)
    @tag1["album"] = read_id3_string(30)
    year_t = read_id3_string(4).to_i
    @tag1["year"] = year_t unless year_t == 0
    comments = @file.read(30)
    if comments[-2] == 0
      @tag1["tracknum"] = comments[-1].to_i
      comments.chop! #remove the last char
    end
    #@tag1["comments"] = comments.sub!(/\0.*$/, '')
    @tag1["comments"] = comments.strip
    @tag1["genre"] = @file.getc
    @tag1["genre_s"] = GENRES[@tag1["genre"]] || ""

    # clear empty tags
    @tag1.delete_if { |k, v| v.respond_to?(:empty?) && v.empty? }
    @tag1.delete("genre") if @tag1["genre"] == 255
    @tag1.delete("tracknum") if @tag1["tracknum"] == 0
  end

  ### reads through @file from current pos until it finds a valid MPEG header
  ### returns the MPEG header as FixNum
  def find_next_frame
    # @file will now be sitting at the best guess for where the MPEG frame is.
    # It should be at byte 0 when there's no id3v2 tag.
    # It should be at the end of the id3v2 tag or the zero padding if there
    #   is a id3v2 tag.

    #dummyproof = @file.stat.size - @file.pos => WAS TOO MUCH
    dummyproof = [ @file.stat.size - @file.pos, 2000000 ].min
    dummyproof.times do |i|
      if @file.getc == 0xff
        data = @file.read(3)
	raise Mp3InfoError if @file.eof?
        head = 0xff000000 + (data[0] << 16) + (data[1] << 8) + data[2]
        if check_head(head)
            return head
        else
            @file.seek(-3, IO::SEEK_CUR)
        end
      end
    end
    raise Mp3InfoError, "cannot find a valid frame after reading #{dummyproof} bytes"
  end

  ### checks the given header to see if it is valid
  ###  head (fixnum) = 4 byte value to test for MPEG header validity
  ### returns true if valid, false if not
  def check_head(head)
    return false if head & 0xffe00000 != 0xffe00000    # 11 bit MPEG frame sync
    return false if head & 0x00060000 == 0x00060000    #  2 bit layer type
    return false if head & 0x0000f000 == 0x0000f000    #  4 bit bitrate
    return false if head & 0x0000f000 == 0x00000000    #        free format bitstream
    return false if head & 0x00000c00 == 0x00000c00    #  2 bit frequency
    return false if head & 0xffff0000 == 0xfffe0000
    true
  end

  ### returns the selected bit range (b, a) as a number
  ### NOTE: b > a  if not, returns 0
  def bits(n, b, a)
    t = 0
    b.downto(a) { |i| t += t + n[i] }
    t
  end
end

if $0 == __FILE__
  while filename = ARGV.shift
    begin
      info = Mp3Info.new(filename)
      puts filename
      #puts "MPEG #{info.mpeg_version} Layer #{info.layer} #{info.vbr ? "VBR" : "CBR"} #{info.bitrate} Kbps \
      #{info.channel_mode} #{info.samplerate} Hz length #{info.length} sec."
      puts info
    rescue Mp3InfoError => e
      puts "#{filename}\nERROR: #{e}"
    end
    puts
  end
end

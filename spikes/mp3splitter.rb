class FrameHeader

  LAYER_DESCRIPTION_LOCATION  = 0x60000
  MPEG_VERSION_LOCATION       = 0x80000
  BITRATE_LOCATION            = 0xF000
  SAMPLING_LOCATION           = 0xC00
  PADDING_LOCATION            = 0X200
  PROTECTION_BIT_LOCATION     = 0x10000  
  
  LAYER3                      = 0x20000
  # V2                        = 0x0
  V1                          = 0x80000

  # invalid bits are 11
  V1_SAMPLING_RATES = { 0x000 => 44_100,
                        0x400 => 48_000,
                        0x800 => 32_000
                      }
                            
  V2_SAMPLING_RATES = { 0x000 => 22_050,
                        0x400 => 24_000,
                        0x800 => 16_000
                      }

  # invalid if bits are 0000 or 1111
  V1_BITRATES = { 0x1000 => 32_000, 
                  0x2000 => 40_000,
                  0x3000 => 48_000,
                  0x4000 => 56_000,
                  0x5000 => 64_000,
                  0x6000 => 80_000,
                  0x7000 => 96_000,
                  0x8000 => 112_000,
                  0x9000 => 128_000,
                  0xA000 => 160_000,
                  0xB000 => 192_000,
                  0xC000 => 224_000,
                  0xD000 => 256_000,
                  0xE000 => 320_000 }

  V2_BITRATES = { 0x1000 => 8_000, 
                  0x2000 => 16_000,
                  0x3000 => 24_000,
                  0x4000 => 32_000,
                  0x5000 => 40_000,
                  0x6000 => 48_000,
                  0x7000 => 56_000,
                  0x8000 => 64_000,
                  0x9000 => 80_000,
                  0xA000 => 96_000,
                  0xB000 => 112_000,
                  0xC000 => 128_000,
                  0xD000 => 144_000,
                  0xE000 => 160_000 }
  
  attr_reader :header_bytes
  
  def initialize(header_bytes)
    @header_bytes = header_bytes
  end
  
  def pad
    padding_bit == 0 ? 0 : 1
  end
  
  def protection_bit?
    protection_bit == PROTECTION_BIT_LOCATION
  end
  
  def self.frame_sync?(bytes)
    (bytes | 0xF) == 0xFFFF
  end
  
  def layer_flags
    header_bytes & LAYER_DESCRIPTION_LOCATION
  end
  
  def mpeg_version_flags
    header_bytes & MPEG_VERSION_LOCATION
  end

  def bitrate_flags
    header_bytes & BITRATE_LOCATION
  end
  
  def sampling_rate_flags
    header_bytes & SAMPLING_LOCATION
  end
  
  def data_length
    (144 * bitrate / sampling_rate + pad) - 4
  end
  
  def duration
    data_length / (bitrate / 8.0) 
  end
  
  def packed_header_bytes
    [header_bytes].pack("N")
  end
  
  protected
  
  def sampling_rate
    mpeg_version_flags == V1 ? V1_SAMPLING_RATES[sampling_rate_flags].to_f : V2_SAMPLING_RATES[sampling_rate_flags].to_f
  end
  
  def bitrate
    mpeg_version_flags == V1 ? V1_BITRATES[bitrate_flags].to_f : V2_BITRATES[bitrate_flags].to_f
  end
  
  def protection_bit
    header_bytes & PROTECTION_BIT_LOCATION
  end
  
  def padding_bit
    header_bytes & PADDING_LOCATION
  end
  
  
end

def find_frame_header_for(file, most_significant_byte)
  least_significant_byte = read_byte_for(file)
  return nil unless least_significant_byte
  bytes = (most_significant_byte << 8) + least_significant_byte
  return FrameHeader.new((bytes << 16) + (file.read(2).unpack('n').first)) if FrameHeader.frame_sync?(bytes)
  return find_frame_header_for(file, least_significant_byte)
end

def read_byte_for(file)
  byte = file.read(1) 
  return byte.unpack('C').first unless byte.nil?
end

def in_range?(duration)
  (14.5..16.6).include?(duration)
end


File.open('/Users/admin/Desktop/rehab_again.mp3','w+') do |write_file|
  File.open("/Users/admin/Desktop/rehab.mp3", 'r') do |file|
    duration = 0.0
    while byte = read_byte_for(file)
      frame_header = find_frame_header_for(file, byte)
      break if frame_header.nil?
      data = file.read(frame_header.data_length)
      duration += frame_header.duration
      if in_range?(duration)
        write_file << frame_header.packed_header_bytes
        write_file << data
      end
    end
  end
end

# puts "frame_length: #{frame_header.frame_length}"
#     puts "layer " + sprintf("0x%x", frame_header.layer_desciption)
#     puts "mpeg " +  sprintf("0x%x", frame_header.mpeg_version)
#     puts "bitrate " + sprintf("0x%x", frame_header.bitrate)
#     puts " "

#!/usr/bin/env macruby
framework 'Cocoa'

class NSSoundTrack
  def initialize(params)
    raise if params.nil?
    @file_location = params[0]
    @start_time = params[1]
    @end_time = params[2]
    @after = params[3]
    @ns_sound = NSSound.alloc.initWithContentsOfFile @file_location, byReference: true
    @ns_sound.currentTime = @start_time if @start_time
  end
  
  def play
    @ns_sound.play or @ns_sound.resume
  end
  
  def pause
    @ns_sound.pause
  end
  
  def stop
    @ns_sound.stop
  end
  
  def playing?
    @ns_sound.playing?
  end
  
  def pause_after?
    @after == 'pause'
  end
  
  def passed_end_time?
    return unless @end_time
    @ns_sound.currentTime >= @end_time
  end
end

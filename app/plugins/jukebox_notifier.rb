# To use the notifier for all the projects on a cc.rb server:
#   Create a jukebox_notifier.yml file with one line:
#   default_jukebox: http://localhost:5904/
#
# Sample per project configuration:
# <pre><code>Project.configure do |project|
#   ...
#   project.jukebox_notifier.jukeboxes = ['http://localhost:5904/']
#   ...
# end</code></pre>

require 'net/http'
require 'timeout'

class JukeboxNotifier
  attr_accessor :jukeboxes
  attr_reader   :logger
  
  def self.shared_settings
    YAML.load_file(File.join(RAILS_ROOT, "config", "jukebox_notifier.yml")) rescue nil
  end
  
  def self.default_jukebox
    shared_settings["default_jukebox"] if shared_settings
  end
  
  def initialize(project = nil)
    @jukeboxes = [JukeboxNotifier.default_jukebox].compact
    @logger =Logger.new("#{RAILS_ROOT}/log/jukebox_notifier.log")
  end

  def build_started(build)
    hammertime "build_started"
  end
  
  def build_finished(build)
    if build.successful?
      hammertime "build_successful"  
    else
      hammertime "build_failed"
    end
  end

  private
  
  def hammertime(snippet_name)
    @jukeboxes.each do |jukebox|
      begin
        Timeout.timeout(15) do
          Net::HTTP.get_response URI.parse("#{jukebox}/hammertime/add_for/#{snippet_name}")
        end
      rescue Exception, Timeout::Error => e
        logger.error "Error connecting to #{jukebox}: #{e.message}"
      end
    end
  end

end

Project.plugin :jukebox_notifier if defined? Project

namespace :jukebox do
  namespace :db do

    [:development, :test].each do |env|
      namespace :delete do
        desc "delete #{env} database"
        task :"#{env}" do
          db_file = "#{RAILS_ROOT}/db/#{env}.sqlite3"
          File.delete(db_file) if File.exists?(db_file)
        end
      end
    end
    
    desc 'resets jukebox dev database'
    task :reset  => [:"delete:development", :environment, :'db:migrate'] do
      Dir[JUKEBOX_MUSIC_FILES].each do |file|
        PlaylistEntry.create! :file_location => file
      end
    end
  end
  
  desc "add a track for someone"
  task :add_for do |person|
    puts "Adding a track for #{person}..."
    system("curl http://#{host}:#{port}/playlist/add_for/#{person}")
  end

  # add_for_task_pat = /^jukebox:add_for_(\w+)$/
  # 
  # add_for = proc do |taskname|
  #   name = taskname[add_for_task_pat, 1]
  #   system("curl http://#{host}:#{port}/playlist/add_for/#{name} > /dev/null")
  #   "Added a track for #{name}."
  # end
  # 
  # rule add_for_task_pat => add_for do |t|
  #   puts t.source
  # end
    
  def host
    "Tanto.local"
  end
  
  def port
    "3000"
  end
end

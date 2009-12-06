require 'readline'

Rake::Task[:default].prerequisites.clear
Rake::Task[:default].enhance [:pc]

task :pc => %w[
  log:clear
  test
]

desc "Run to check in"
task :commit => :pc do
  message = Readline.readline("Commit message: ").chomp
  command = %[git commit -a -m "#{message}"]
  puts command
  puts %x[#{command}]
end

task :push => :commit do
  command = %[git pull]
  puts command
  puts %x[#{command}]

  Rake::Task['pc'].invoke
  
  command = %[git push]
  puts command
  puts %x[#{command}]  
end

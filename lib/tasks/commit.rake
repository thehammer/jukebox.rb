require 'readline'

Rake::Task[:default].prerequisites.clear
Rake::Task[:default].enhance [:pc]

task :pc => %w[
  log:clear
  svn:delete
  svn:up
  svn:fail_on_conflict
  test
  svn:add
]

desc "Run to check in"
task :ci => :pc do
  message = Readline.readline("Commit message: ").chomp
  command = %[git commit -m "#{message}"]

  puts command
  puts %x[#{command}]
end

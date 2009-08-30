namespace :svn do
  
  desc 'rake for svn st'
  task :st do
    puts %x[svn st]
  end
  
  desc 'check for svn conflicts and fail if one is found'
  task :fail_on_conflict do
    puts "checking for conflicts"
    system "svn st | grep '^C '"
    raise "svn conflicts detected" if $?.success?
  end
  
  desc 'rake for svn up'
  task :up do
    puts %x[svn up]
  end

  desc 'rake for svn add'
  task :add do
    %x[svn st].split(/\n/).each do |line|
      trimmed_line = line.delete('?').lstrip
      if line[0,1] =~ /\?/
        %x[svn add '#{trimmed_line}']
        puts %[added '#{trimmed_line}']
      end
    end
  end
  
  desc 'rake for svn delete'
  task :delete do
    %x[svn st].split(/\n/).each do |line|
      trimmed_line = line.delete('!').lstrip
      if line[0,1] =~ /\!/
        %x[svn rm #{trimmed_line}]
        puts %[removed #{trimmed_line}]
      end
    end
  end
  
  desc 'strip svn folders'
  task :strip do
    Find.find(File.expand_path('.')) { |path| %x[rm -rf #{path}] if path =~ /\.svn$/ }
  end

end
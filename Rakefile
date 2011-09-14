require 'active_record'
require 'yaml'
require 'logger'
require 'pathname'
require './models/directory'
require './models/file'

ActiveSupport::LogSubscriber.colorize_logging=false

desc 'Create DirDiff inital database'
task :init, :name, :path do |task, args|
  if File.exist? "db/#{args[:name]}.db"
    puts "Database exists!"
    return
  end
  path = Pathname.new args[:path]
  unless path.exist?
    puts "Path don't exists."
    return
  end
  unless path.directory?
    puts "Path is not a directory!"
    return
  end

  Rake::Task[:create_tables].invoke args[:name] 
  
  puts "Saving directory structure"
  puts "Pleas wait ..."

  dir = DirDiff::Directory.new :name => path.basename.to_s
  queue = Queue.new
  DirPath = Struct.new :dir, :path
  queue << DirPath.new(dir, path)
  while not queue.empty?
    current = queue.pop
    current.path.each_child do |child|
      if child.directory?
        child_dir = DirDiff::Directory.create(:name => child.basename.to_s, :parent => current.dir)
        queue << DirPath.new(child_dir, child)
      end
      DirDiff::File.create(:name => child.basename.to_s, :parent => current.dir) if child.file?
    end
  end

  puts "Done"
end

task :connection, :database do |task, args|
  ActiveRecord::Base.establish_connection({:adapter => "sqlite3", :database => "db/#{args[:database]}.db"})
  ActiveRecord::Base.logger = Logger.new(File.open("log/#{args[:database]}.log", 'a'))
end

task :create_tables, :database do |task, args|
  Rake::Task[:connection].invoke(args[:database])
  ActiveRecord::Migrator.migrate('db/migrate', nil)
end

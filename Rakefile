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
      else
        DirDiff::File.create(:name => child.basename.to_s, :parent => current.dir) if child.file?
      end
    end
  end

  puts "Done"
end

task :connect, :database do |task, args|
  ActiveRecord::Base.establish_connection({:adapter => "sqlite3", :database => "db/#{args[:database]}.db"})
  ActiveRecord::Base.logger = Logger.new(File.open("log/#{args[:database]}.log", 'a'))
end

task :create_tables, :database do |task, args|
  Rake::Task[:connect].invoke(args[:database])
  ActiveRecord::Migrator.migrate('db/migrate', nil)
end

desc "Generate directury structrue diff from what saved in db"
task :diff, :name, :path, :out_file do |task, args|
  unless File.exist? "db/#{args[:name]}.db"
    puts "Database do not exist!"
    return
  end

  path = Pathname.new args[:path]
  unless path.exist?
    puts "Path don't exist anymore!"
    return
  end
  unless path.directory?
    puts "Path is not a directory!"
    return
  end

  Rake::Task[:connect].invoke args[:name] 
  
  puts "Reading directory structure"
  puts "Pleas wait ..."

  out = File.open args[:out_file], "w"
  out.write "#{path}\n"

  dir = DirDiff::Directory.first
  queue = Queue.new
  DirPath = Struct.new :dir, :path
  queue << DirPath.new(dir, path)
  while not queue.empty?
    current = queue.pop

    already_exits = []
    unless current.dir.nil?
      already_exits = current.dir.subdirectories.map { |subdir| subdir.name }
      already_exits += current.dir.files.map { |file| file.name }
    end

    what_is_now = current.path.children.map { |child| child.basename.to_s }

    added = what_is_now - already_exits
    removed = already_exits - what_is_now

    added.each do |entry|
      out.write "+ #{current.path + entry}\n"
    end
    removed.each do |entry|
      out.write "- #{current.path + entry}\n"
    end

    current.path.children.each do |child|
      if child.directory?
        child_dir = nil
        child_dir = current.dir.subdirectories.where(:name => child.basename.to_s).limit(1).first unless current.dir.nil?
        queue << DirPath.new(child_dir, child)
      end
    end
  end

  puts "Done"


end

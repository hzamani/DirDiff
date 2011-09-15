#!/usr/bin/env ruby
require 'optparse'
require 'pathname'
require 'tempfile'
require './db/utils'
require './utils'

program_name = File.basename($0)
options = {}
args = nil

OptionParser.new do |o|
  o.on("-O", "--out OUT") { |v| options["out"] = v }

  o.banner = <<END_BANNER
Usage:
  #{program_name} init PATH [db_name]
  #{program_name} diff PATH [db_name] [--out=OUTFILE]
  #{program_name} copy PATH DEST

  in copy PATH can be ither a diff file or a directory
END_BANNER

  args = o.parse ARGV
end

if args.nil? or args.empty?
  puts "No command spesified"
  exit 1
end

command = args[0]
args.delete_at 0

case command
when "init"
  if args[0].nil?
    puts "PATH is required"
    exit 1
  end

  path = Pathname.new args[0]
  unless path.exist?
    puts "Path do not exist."
    exit 1
  end
  unless path.directory?
    puts "Path is not a directory."
    exit 1
  end

  if args[1].nil?
    db = "db/#{path.basename}.db"
  else
    db = "db/#{args[1]}.db"
  end

  create_tables db

  puts "Saving directory structure"
  puts "Pleas wait ..."
  save_structure path
  puts "Done"

when "diff"
  if args[0].nil?
    puts "PATH is required"
    exit 1
  end

  path = Pathname.new args[0]
  unless path.exist?
    puts "Path do not exist."
    exit 1
  end
  unless path.directory?
    puts "Path is not a directory."
    exit 1
  end

  if args[1].nil?
    db = "db/#{path.basename}.db"
  else
    db = "db/#{args[1]}.db"
  end

  connect db

  puts "Reading directory structure"
  puts "Pleas wait ..."
  diff path, options
  puts "Done"

when "copy"
  if args[0].nil?
    puts "PATH is required"
    exit 1
  end

  path = Pathname args[0]
  unless path.exist?
    puts "Path do not exist."
    exit 1
  end
  if path.directory?
    diff_file = Tempfile.new "diff"
    connect "db/#{path.basename}.db"
    diff path, {"out" => diff_file.path}
  elsif path.file?
    diff_file = path.to_s
  end

  if args[1].nil?
    puts "DEST is required"
    exit 1
  end

  copy diff_file, args[1] 
end

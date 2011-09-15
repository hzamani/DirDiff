require './models/directory'
require './models/file'

DirPath = Struct.new :dir, :path

def save_structure path, db
  dir = DirDiff::Directory.new :name => path.basename.to_s
  
  queue = Queue.new
  queue << DirPath.new(dir, path)

  while not queue.empty?
    current = queue.pop
    current.path.each_child do |child|
      if child.directory?
        child_dir = DirDiff::Directory.create(
          :name => child.basename.to_s,
          :parent => current.dir
        )
        queue << DirPath.new(child_dir, child)
      elsif child.file?
        DirDiff::File.create(
          :name => child.basename.to_s,
          :parent => current.dir
        )
      end
    end
  end
end

def diff path, options={}
  out = options["out"]
  out = File.open(out, "w") unless out.nil?

  output = lambda { |s| if out.nil? then puts s else out.write "#{s}\n" end }
  output[path]

  dir = DirDiff::Directory.first
  queue = Queue.new
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
      output["+ #{current.path + entry}\n"]
    end
    removed.each do |entry|
      output["- #{current.path + entry}\n"]
    end

    current.path.children.each do |child|
      if child.directory?
        unless current.dir.nil?
          child_dir = current.dir.subdirectories.where(:name => child.basename.to_s).limit(1).first
        else
          child_dir = nil
        end
        queue << DirPath.new(child_dir, child)
      end
    end
  end

  out.close unless out.nil?
end

def copy diff_file, dest
  diff = File.open diff_file
  basepath = Pathname diff.readline[0..-2]
  dest = Pathname.new(dest) + basepath.basename
  dest.mkpath

  diff.each_line do |line|
    if line[0] == '+'
      entry = Pathname line[2..-2]
      current_dest = dest + entry.relative_path_from(basepath)
      if entry.directory?
        dir = dest + current_dest
        dir.mkpath
      elsif entry.file?
        current_dest.dirname.mkpath
        FileUtils.copy(entry, current_dest)
      end
    end
  end
end

module DirDiff
class File < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Directory'

  def path
    ancestor = parent
    path = name
    while not ancestor.nil?
      path = File.join(ancestor.name,path)
      ancestor = ancestor.parent
    end
    path = File::SEPARATOR if path.empty?
    path
  end

  def to_s
    path
  end
end
end

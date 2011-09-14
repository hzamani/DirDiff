module DirDiff
class Directory < ActiveRecord::Base
  has_many :subdirectories,
    :class_name => 'Directory',
    :dependent => :destroy,
    :foreign_key => 'parent_id',
    :uniq => true,
    :order => 'name'
  has_many :files,
    :class_name => 'File',
    :dependent => :destroy,
    :foreign_key => 'parent_id',
    :uniq => true,
    :order => 'name'
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

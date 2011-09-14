class CreateDirectories < ActiveRecord::Migration
  def change
    create_table :directories do |t|
      t.string  :name
      t.integer :parent_id
    end
  end
end

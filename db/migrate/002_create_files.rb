class CreateFiles < ActiveRecord::Migration
  def change
    create_table :files do |t|
      t.string  :name
      t.integer :parent_id
    end
  end
end

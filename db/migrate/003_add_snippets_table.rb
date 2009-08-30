class AddSnippetsTable < ActiveRecord::Migration
  def self.up
    create_table :snippets do |t|
      t.column :name, :string
      t.column :file_location, :string
      t.column :start_time, :float
      t.column :end_time, :float
    end
  end

  def self.down
    drop_table :snippets
  end
end
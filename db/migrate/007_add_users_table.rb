class AddUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string
      t.column :gravatar_id, :string
    end
  end

  def self.down
    drop_table :users
  end
end

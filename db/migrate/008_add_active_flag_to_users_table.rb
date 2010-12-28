class AddActiveFlagToUsersTable < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean, :default => 0
  end

  def self.down
    drop_column :users, :active
  end
end

class AddContinuousPlayToPlayerStatusTable < ActiveRecord::Migration
  def self.up
    add_column :player_statuses, :continuous_play, :boolean, :default => 1
  end

  def self.down
    drop_column :player_statuses, :continuous_play
  end
end
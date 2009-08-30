class AddPlayerStatusTable < ActiveRecord::Migration
  def self.up
    create_table :player_statuses do |t|
        t.column :status, :string, :default => PlayerStatus::PLAY
    end
    
    PlayerStatus.create!
  end

  def self.down
    drop_table :player_statuses
  end
end
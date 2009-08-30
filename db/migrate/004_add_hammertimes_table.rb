class AddHammertimesTable < ActiveRecord::Migration
  def self.up
    create_table :hammertimes do |t|
      t.column :snippet_id, :integer
      t.column :after, :string, :default => PlayerStatus::PLAY
    end
  end

  def self.down
    drop_table :hammertimes
  end
end
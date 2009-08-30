class AddSkipFlagToPlaylistEntriesTable < ActiveRecord::Migration
  def self.up
    add_column :playlist_entries, :skip, :boolean, :default => 0
  end

  def self.down
    drop_column :playlist_entries, :skip
  end
end
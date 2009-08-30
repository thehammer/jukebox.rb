class AddPlaylistEntriesTable < ActiveRecord::Migration
  def self.up
    create_table :playlist_entries do |t|
        t.column :file_location, :string
        t.column :status, :string, :default => PlaylistEntry::UNPLAYED
    end
  end

  def self.down
    drop_table :playlist_entries
  end
end
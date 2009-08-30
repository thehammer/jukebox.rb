# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 6) do

  create_table "hammertimes", :force => true do |t|
    t.integer "snippet_id"
    t.string  "after",      :default => "play"
  end

  create_table "player_statuses", :force => true do |t|
    t.string  "status",          :default => "play"
    t.boolean "continuous_play", :default => true
  end

  create_table "playlist_entries", :force => true do |t|
    t.string  "file_location"
    t.string  "status",        :default => "unplayed"
    t.boolean "skip",          :default => false
  end

  create_table "snippets", :force => true do |t|
    t.string "name"
    t.string "file_location"
    t.float  "start_time"
    t.float  "end_time"
  end

end

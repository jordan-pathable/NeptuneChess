# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140413154109) do

  create_table "coordinates", force: true do |t|
    t.integer  "path_id"
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.string   "fen"
    t.string   "white"
    t.string   "black"
    t.boolean  "active"
    t.datetime "started_at"
    t.datetime "last_move_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moves", force: true do |t|
    t.integer  "game_id"
    t.string   "source"
    t.string   "target"
    t.string   "flag"
    t.string   "piece"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", force: true do |t|
    t.integer  "x"
    t.integer  "y"
    t.string   "occupant"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paths", force: true do |t|
    t.integer  "move_id"
    t.boolean  "processed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

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

ActiveRecord::Schema.define(version: 20141008043147) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "cities", force: true do |t|
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.integer  "requests",   default: 0
    t.boolean  "available",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rides", force: true do |t|
    t.integer  "user_id"
    t.integer  "vehicle_id"
    t.datetime "scheduled_at"
    t.string   "relation"
    t.string   "address"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "phone",                  limit: 8
    t.string   "password_digest"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "zip_code"
    t.string   "status"
  end

  create_table "vehicles", force: true do |t|
    t.string   "make"
    t.string   "model"
    t.integer  "year"
    t.string   "style"
    t.text     "description"
    t.integer  "mileage"
    t.integer  "condition"
    t.hstore   "options"
    t.hstore   "preliminary_value"
    t.hstore   "agreed_value"
    t.decimal  "sold_price"
    t.string   "status"
    t.boolean  "inspection"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

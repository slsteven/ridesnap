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

ActiveRecord::Schema.define(version: 20141214024114) do

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

  create_table "garages", force: true do |t|
    t.integer  "user_id"
    t.integer  "vehicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "garages", ["user_id"], name: "index_garages_on_user_id", using: :btree
  add_index "garages", ["vehicle_id"], name: "index_garages_on_vehicle_id", using: :btree

  create_table "images", force: true do |t|
    t.integer  "vehicle_id"
    t.string   "url"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["vehicle_id"], name: "index_images_on_vehicle_id", using: :btree

  create_table "rides", force: true do |t|
    t.integer  "user_id"
    t.integer  "vehicle_id"
    t.datetime "scheduled_at"
    t.integer  "relation"
    t.string   "address"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cancel",       default: false
  end

  add_index "rides", ["relation"], name: "index_rides_on_relation", using: :btree
  add_index "rides", ["user_id"], name: "index_rides_on_user_id", using: :btree
  add_index "rides", ["vehicle_id"], name: "index_rides_on_vehicle_id", using: :btree

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

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["status"], name: "index_users_on_status", using: :btree

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
    t.decimal  "sold_price"
    t.string   "status"
    t.boolean  "inspection"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "closest_color"
    t.string   "vin"
    t.decimal  "agreed_value"
  end

  add_index "vehicles", ["closest_color"], name: "index_vehicles_on_closest_color", using: :btree
  add_index "vehicles", ["condition"], name: "index_vehicles_on_condition", using: :btree
  add_index "vehicles", ["status"], name: "index_vehicles_on_status", using: :btree
  add_index "vehicles", ["zip_code"], name: "index_vehicles_on_zip_code", using: :btree

end

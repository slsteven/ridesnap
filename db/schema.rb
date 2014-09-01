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

ActiveRecord::Schema.define(version: 20140831200231) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "rides", force: true do |t|
    t.integer  "user_id"
    t.integer  "vehicle_id"
    t.datetime "datetime"
    t.string   "relation"
    t.boolean  "owner"
    t.string   "address"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "phone"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vehicles", force: true do |t|
    t.string   "make"
    t.string   "model"
    t.integer  "year"
    t.string   "style"
    t.integer  "mileage"
    t.string   "condition"
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

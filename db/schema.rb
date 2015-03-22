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

ActiveRecord::Schema.define(version: 20150321035604) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "authentications", force: :cascade do |t|
    t.integer  "vehicle_id"
    t.string   "type"
    t.string   "grant"
    t.jsonb    "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "authentications", ["type"], name: "index_authentications_on_type", using: :btree
  add_index "authentications", ["vehicle_id"], name: "index_authentications_on_vehicle_id", using: :btree

  create_table "cities", force: :cascade do |t|
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.integer  "requests",   default: 0
    t.boolean  "available",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "codes", force: :cascade do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "codes", ["code"], name: "index_codes_on_code", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer  "vehicle_id"
    t.string   "url"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["vehicle_id"], name: "index_images_on_vehicle_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "vehicle_id"
    t.string   "type"
    t.jsonb    "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "ended_at"
  end

  add_index "notifications", ["ended_at"], name: "index_notifications_on_ended_at", using: :btree
  add_index "notifications", ["type"], name: "index_notifications_on_type", using: :btree
  add_index "notifications", ["vehicle_id"], name: "index_notifications_on_vehicle_id", using: :btree

  create_table "rides", force: :cascade do |t|
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

  create_table "users", force: :cascade do |t|
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

  create_table "vehicles", force: :cascade do |t|
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
    t.boolean  "financed"
    t.string   "model_pretty"
    t.string   "external_ad"
    t.jsonb    "report",            default: {}
    t.jsonb    "option_list",       default: {}
  end

  add_index "vehicles", ["closest_color"], name: "index_vehicles_on_closest_color", using: :btree
  add_index "vehicles", ["condition"], name: "index_vehicles_on_condition", using: :btree
  add_index "vehicles", ["status"], name: "index_vehicles_on_status", using: :btree
  add_index "vehicles", ["zip_code"], name: "index_vehicles_on_zip_code", using: :btree

end

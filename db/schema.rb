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

ActiveRecord::Schema.define(version: 20131001155817) do

  create_table "blocks", force: true do |t|
    t.integer  "street_id"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", force: true do |t|
    t.string   "name"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns_cities", id: false, force: true do |t|
    t.integer "campaign_id", null: false
    t.integer "city_id",     null: false
  end

  add_index "campaigns_cities", ["campaign_id", "city_id"], name: "index_campaigns_cities_on_campaign_id_and_city_id", unique: true

  create_table "cities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cities", ["name"], name: "index_cities_on_name", unique: true

  create_table "outing_lines", force: true do |t|
    t.integer  "outing_id",  null: false
    t.text     "line"
    t.integer  "street_id"
    t.text     "numbers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outings", force: true do |t|
    t.integer  "user_id",     null: false
    t.integer  "campaign_id", null: false
    t.datetime "date"
    t.string   "status"
    t.integer  "city_id",     null: false
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streets", force: true do |t|
    t.integer  "city_id",         null: false
    t.string   "name"
    t.string   "other_spellings"
    t.string   "metaphone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "streets", ["name"], name: "index_streets_on_name", unique: true

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end

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

ActiveRecord::Schema.define(version: 20180414200656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.integer "user_id"
    t.integer "plan_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "plan_id"
    t.boolean "available"
  end

  create_table "option_plans", force: :cascade do |t|
    t.integer "option_id"
    t.integer "plan_id"
  end

  create_table "options", force: :cascade do |t|
    t.string "title"
    t.datetime "meeting_time"
    t.boolean "reusable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "rough_time"
    t.integer "owner_id"
    t.string "title"
    t.string "user_intro"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "minimum_attendee_count"
    t.integer "tz_offset"
  end

  create_table "responses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "offer_plan_id"
    t.boolean "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "access_token"
    t.string "scope"
    t.string "user_id"
    t.string "team_name"
    t.string "team_id"
    t.string "bot_user_id"
    t.string "bot_access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "slack_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "team_id"
  end

end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_11_28_050146) do
  create_table "event_recipients", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "recipient_id", null: false
    t.decimal "budget"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_recipients_on_event_id"
    t.index ["recipient_id"], name: "index_event_recipients_on_recipient_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.decimal "budget"
    t.string "location"
    t.string "theme"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "gift_ideas", force: :cascade do |t|
    t.string "title"
    t.decimal "price"
    t.string "status"
    t.string "url"
    t.text "notes"
    t.integer "event_recipient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_recipient_id"], name: "index_gift_ideas_on_event_recipient_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.string "name"
    t.integer "age"
    t.text "likes"
    t.text "dislikes"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "relationship"
    t.index ["user_id"], name: "index_recipients_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.date "birthday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "event_recipients", "events"
  add_foreign_key "event_recipients", "recipients"
  add_foreign_key "events", "users"
  add_foreign_key "gift_ideas", "event_recipients"
  add_foreign_key "recipients", "users"
end

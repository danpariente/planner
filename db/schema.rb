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

ActiveRecord::Schema[8.1].define(version: 2026_06_05_000001) do
  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.date "target_date"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.string "hex"
    t.string "key", null: false
    t.string "name"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "key"], name: "index_categories_on_account_id_and_key", unique: true
    t.index ["account_id"], name: "index_categories_on_account_id"
  end

  create_table "days", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.decimal "goal_hours", precision: 4, scale: 1, default: "0.0"
    t.text "notes"
    t.json "slots", default: []
    t.integer "stars", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "date"], name: "index_days_on_account_id_and_date", unique: true
    t.index ["account_id"], name: "index_days_on_account_id"
  end

  create_table "goals", force: :cascade do |t|
    t.integer "account_id"
    t.string "achieved"
    t.string "area"
    t.datetime "created_at", null: false
    t.boolean "done", default: false, null: false
    t.integer "position", default: 0
    t.string "previous"
    t.string "target"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_goals_on_account_id"
  end

  create_table "login_tokens", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "attempts", default: 0, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["account_id"], name: "index_login_tokens_on_account_id"
    t.index ["token"], name: "index_login_tokens_on_token", unique: true
  end

  create_table "materials", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.integer "done_count", default: 0
    t.integer "position", default: 0
    t.string "title"
    t.integer "total_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_materials_on_account_id"
  end

  create_table "month_notes", force: :cascade do |t|
    t.integer "account_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.date "on_date", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "on_date"], name: "index_month_notes_on_account_id_and_on_date", unique: true
    t.index ["account_id"], name: "index_month_notes_on_account_id"
  end

  create_table "month_todos", force: :cascade do |t|
    t.integer "account_id"
    t.string "body"
    t.datetime "created_at", null: false
    t.boolean "done", default: false, null: false
    t.string "period", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_month_todos_on_account_id"
    t.index ["period"], name: "index_month_todos_on_period"
  end

  create_table "plan_items", force: :cascade do |t|
    t.string "body"
    t.string "category", default: "cliente"
    t.datetime "created_at", null: false
    t.integer "day_id", null: false
    t.boolean "done", default: false, null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["day_id"], name: "index_plan_items_on_day_id"
  end

  create_table "priorities", force: :cascade do |t|
    t.string "body"
    t.datetime "created_at", null: false
    t.integer "day_id", null: false
    t.boolean "done", default: false, null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["day_id"], name: "index_priorities_on_day_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "account_id"
    t.string "body"
    t.string "category"
    t.datetime "created_at", null: false
    t.boolean "done", default: false, null: false
    t.date "due_on"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tasks_on_account_id"
  end

  create_table "timetable_cells", force: :cascade do |t|
    t.integer "account_id"
    t.string "body"
    t.integer "col", null: false
    t.datetime "created_at", null: false
    t.integer "row", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "row", "col"], name: "index_timetable_cells_on_account_id_and_row_and_col", unique: true
    t.index ["account_id"], name: "index_timetable_cells_on_account_id"
  end

  add_foreign_key "categories", "accounts"
  add_foreign_key "days", "accounts"
  add_foreign_key "goals", "accounts"
  add_foreign_key "login_tokens", "accounts"
  add_foreign_key "materials", "accounts"
  add_foreign_key "month_notes", "accounts"
  add_foreign_key "month_todos", "accounts"
  add_foreign_key "plan_items", "days"
  add_foreign_key "priorities", "days"
  add_foreign_key "tasks", "accounts"
  add_foreign_key "timetable_cells", "accounts"
end

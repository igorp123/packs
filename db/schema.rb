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

ActiveRecord::Schema[7.1].define(version: 2024_08_24_151044) do
  create_table "batches", force: :cascade do |t|
    t.string "number"
    t.datetime "expiration_date"
    t.integer "drug_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drug_id"], name: "index_batches_on_drug_id"
  end

  create_table "drugs", force: :cascade do |t|
    t.string "name"
    t.string "gtin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mnn"
    t.string "form_name"
    t.string "form_doze"
    t.integer "producer_id", null: false
    t.boolean "is_narcotic"
    t.boolean "is_pku"
    t.index ["producer_id"], name: "index_drugs_on_producer_id"
  end

  create_table "firms", force: :cascade do |t|
    t.string "name"
    t.string "mod"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gtins", force: :cascade do |t|
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_rj"
  end

  create_table "producers", force: :cascade do |t|
    t.string "name"
    t.string "inn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sgtins", force: :cascade do |t|
    t.string "number"
    t.string "status"
    t.datetime "status_date"
    t.datetime "last_operation_date"
    t.integer "drug_id", null: false
    t.integer "batch_id", null: false
    t.integer "firm_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_sgtins_on_batch_id"
    t.index ["drug_id"], name: "index_sgtins_on_drug_id"
    t.index ["firm_id"], name: "index_sgtins_on_firm_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_operation_time"
  end

  add_foreign_key "batches", "drugs"
  add_foreign_key "drugs", "producers"
  add_foreign_key "sgtins", "batches"
  add_foreign_key "sgtins", "drugs"
  add_foreign_key "sgtins", "firms"
end

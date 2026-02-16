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

ActiveRecord::Schema[8.1].define(version: 2026_02_02_073503) do
  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_customers_on_created_at"
    t.index ["email"], name: "index_customers_on_email", unique: true
  end

  create_table "email_campaigns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "sent_count", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.string "subject", null: false
    t.integer "total_recipients", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_email_campaigns_on_created_at"
    t.index ["status"], name: "index_email_campaigns_on_status"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.datetime "processed_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["customer_id", "status"], name: "index_orders_on_customer_id_and_status"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["processed_at"], name: "index_orders_on_processed_at"
    t.index ["status"], name: "index_orders_on_status"
  end

  add_foreign_key "orders", "customers"
end

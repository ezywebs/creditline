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

ActiveRecord::Schema.define(version: 20181119022815) do

  create_table "credit_lines", force: :cascade do |t|
    t.decimal  "limit"
    t.decimal  "apr"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.decimal  "available"
    t.datetime "last_statement"
    t.integer  "date_adjust"
  end

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",                               null: false
    t.text     "log",               limit: 1073741823
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "crono_jobs", ["job_id"], name: "index_crono_jobs_on_job_id", unique: true

  create_table "draws", force: :cascade do |t|
    t.decimal  "amount"
    t.integer  "credit_line_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "date_adjust"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal  "amount"
    t.integer  "credit_line_id"
    t.integer  "date_adjust"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

end

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

ActiveRecord::Schema[7.0].define(version: 2025_02_15_111609) do
  create_table "advance_salaries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "tenure"
    t.decimal "amount", precision: 10, scale: 2
    t.bigint "employee_id", null: false
    t.integer "payment_ledger_id"
    t.integer "company_id"
    t.integer "user_id"
    t.string "slug"
    t.boolean "is_payout", default: false
    t.boolean "is_processed", default: false
    t.boolean "is_paid", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["employee_id"], name: "index_advance_salaries_on_employee_id"
    t.index ["slug"], name: "index_advance_salaries_on_slug"
  end

  create_table "advance_salary_payouts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.boolean "is_paid", default: false
    t.string "trn_type"
    t.integer "emp_id"
    t.bigint "advance_salaries_id", null: false
    t.integer "company_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["advance_salaries_id"], name: "index_advance_salary_payouts_on_advance_salaries_id"
  end

  create_table "banks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "bank_name"
    t.string "ac_holder_name"
    t.string "ac_number"
    t.string "ifsc"
    t.integer "company_id"
    t.integer "user_id"
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "logo"
    t.string "name"
    t.text "description"
    t.string "phone"
    t.text "address"
    t.boolean "active"
    t.string "contact_email"
    t.string "contact_number"
    t.string "domain_name"
    t.string "account_number"
    t.string "ifsc"
    t.string "upi_id"
    t.date "incorporation_date"
    t.string "incorporation_country"
    t.string "incorporation_state"
    t.string "incremental_share_certificate_no"
    t.decimal "application_fee", precision: 10, scale: 2
    t.decimal "authorised_capital", precision: 18, scale: 2
    t.decimal "paid_up_capital", precision: 18, scale: 2
    t.decimal "nominal_value", precision: 18, scale: 2
    t.string "pan_no"
    t.string "tan_no"
    t.string "cin_no"
    t.string "gst_no"
    t.boolean "under_maintenance"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "state_gst_id"
  end

  create_table "employee_salaries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "salary_date"
    t.decimal "allowances", precision: 12, scale: 2
    t.json "allowances_breack_up"
    t.decimal "deductions", precision: 12, scale: 2
    t.decimal "installment", precision: 10, scale: 2
    t.json "installment_breckup"
    t.string "installment_ids"
    t.json "deductions_breack_up"
    t.decimal "net_salaries", precision: 18, scale: 2
    t.decimal "gross_salaries", precision: 18, scale: 2
    t.string "slug"
    t.string "payment_type"
    t.integer "cr_ledger_id"
    t.integer "company_id"
    t.integer "user_id"
    t.boolean "is_processed", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id"], name: "index_employee_salaries_on_company_id"
    t.index ["slug"], name: "index_employee_salaries_on_slug"
  end

  create_table "employee_salary_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "allwance", precision: 12, scale: 2
    t.decimal "deduction", precision: 12, scale: 2
    t.decimal "installment", precision: 10, scale: 2
    t.decimal "net_salary", precision: 18, scale: 2
    t.decimal "gross_salary", precision: 18, scale: 2
    t.json "break_up"
    t.string "slug"
    t.bigint "employee_id", null: false
    t.bigint "employee_salaries_id", null: false
    t.integer "company_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id"], name: "index_employee_salary_transactions_on_company_id"
    t.index ["employee_id"], name: "index_employee_salary_transactions_on_employee_id"
    t.index ["employee_salaries_id"], name: "index_employee_salary_transactions_on_employee_salaries_id"
  end

  create_table "employees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "full_name"
    t.string "fathername"
    t.string "mobile"
    t.string "email"
    t.date "dob"
    t.date "joining_date"
    t.string "full_address"
    t.string "aadhaar"
    t.string "pan"
    t.string "designation"
    t.string "job_type"
    t.string "nominee_name"
    t.string "relation_with_nominee"
    t.string "nominee_address"
    t.string "nominee_mobile"
    t.json "salary_settings"
    t.boolean "is_active"
    t.integer "user_id"
    t.integer "company_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["full_name"], name: "index_employees_on_full_name"
    t.index ["mobile"], name: "index_employees_on_mobile", unique: true
  end

  create_table "entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "entry_date"
    t.string "narration"
    t.text "entry_info"
    t.string "slug"
    t.boolean "is_processed", default: false
    t.integer "company_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_reverse", default: false
  end

  create_table "expense_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "company_id"
    t.boolean "is_active", default: true
    t.index ["company_id"], name: "index_expense_categories_on_company_id"
    t.index ["name"], name: "index_expense_categories_on_name"
  end

  create_table "expense_entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "remarks"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0"
    t.integer "payment_ledger_id"
    t.bigint "expense_category_id", null: false
    t.string "slug"
    t.date "transaction_date"
    t.integer "company_id"
    t.boolean "is_processed", default: false
    t.integer "user_id"
    t.boolean "is_reversed", default: false
    t.integer "reverse_id"
    t.index ["company_id"], name: "index_expense_entries_on_company_id"
    t.index ["expense_category_id"], name: "index_expense_entries_on_expense_category_id"
    t.index ["slug"], name: "index_expense_entries_on_slug"
  end

  create_table "fixed_assets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "assets_type"
    t.integer "no_of_unit"
    t.decimal "unit_amount", precision: 20, scale: 2
    t.decimal "total", precision: 20, scale: 2
    t.decimal "gst", precision: 5, scale: 2
    t.decimal "gst_amount", precision: 20, scale: 2
    t.string "slug"
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "hsn"
    t.index ["order_id"], name: "index_fixed_assets_on_order_id"
  end

  create_table "friendly_id_slugs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "journal_entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "entry_type"
    t.string "entry_account_type"
    t.integer "plutus_account_id"
    t.text "remarks"
    t.decimal "amount", precision: 18, scale: 2
    t.string "payment_mode"
    t.string "utr"
    t.date "transfer_date"
    t.string "transfer_mode"
    t.string "bank_name"
    t.string "cheque_no"
    t.date "cheque_date"
    t.date "entry_date"
    t.boolean "is_processed", default: false
    t.string "slug"
    t.bigint "company_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "khata_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.json "paid_to"
    t.string "remarks"
    t.string "payment_type"
    t.date "transaction_date"
    t.decimal "amount", precision: 10, scale: 2
    t.boolean "is_processed", default: false
    t.bigint "khatabook_id", null: false
    t.integer "user_id"
    t.integer "company_id"
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["khatabook_id"], name: "index_khata_transactions_on_khatabook_id"
  end

  create_table "khatabooks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "company_name"
    t.string "pan"
    t.string "tan"
    t.string "address"
    t.string "gst"
    t.string "mobile"
    t.string "email"
    t.boolean "is_active", default: true
    t.string "slug"
    t.integer "plutus_ledger_id"
    t.integer "company_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "aadhar"
    t.integer "state_id"
    t.string "khata_type"
    t.string "ledger_name"
    t.index ["slug", "company_id"], name: "index_khatabooks_on_slug_and_company_id"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.json "paid_from"
    t.date "order_date"
    t.string "order_type"
    t.integer "reference_type"
    t.string "vechile_no"
    t.string "mobile_no"
    t.string "ack_no"
    t.string "irn_no"
    t.integer "company_id"
    t.integer "user_id"
    t.decimal "discount", precision: 10, scale: 2
    t.decimal "grand_total", precision: 30, scale: 2
    t.decimal "gst_paid", precision: 20, scale: 2
    t.decimal "gst_payble", precision: 20, scale: 2
    t.string "slug"
    t.string "invoice_no"
    t.boolean "auto_approved"
    t.boolean "occupied", default: false
    t.decimal "order_profit", precision: 20, scale: 2
    t.boolean "is_processed", default: false
    t.bigint "khatabooks_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_returned", default: false
    t.integer "parent_order_id"
    t.decimal "round_off_amount", precision: 6, scale: 2, default: "0.0"
    t.decimal "discount_percent", precision: 5, scale: 2, default: "0.0"
    t.string "status"
    t.boolean "is_igst", default: false
    t.boolean "is_gst_pending", default: false
    t.index ["company_id", "user_id"], name: "index_orders_on_company_id_and_user_id"
    t.index ["is_returned"], name: "index_orders_on_is_returned"
    t.index ["khatabooks_id"], name: "index_orders_on_khatabooks_id"
    t.index ["occupied"], name: "index_orders_on_occupied"
  end

  create_table "plutus_accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.boolean "contra", default: false
    t.integer "company_id"
    t.string "slug"
    t.integer "code"
    t.boolean "is_system"
    t.integer "group_id"
    t.boolean "is_depreciated"
    t.boolean "show_in_daybook"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "is_depreciation"
    t.string "depreciation_type"
    t.boolean "is_liquid", default: false
    t.boolean "is_bank", default: false
    t.boolean "is_lender", default: false
    t.integer "user_id"
    t.decimal "temp_balance", precision: 18, scale: 2, default: "0.0"
    t.index ["code"], name: "index_plutus_accounts_on_code", unique: true
    t.index ["company_id"], name: "index_plutus_accounts_on_company_id"
    t.index ["name", "type"], name: "index_plutus_accounts_on_name_and_type"
    t.index ["slug"], name: "index_plutus_accounts_on_slug", unique: true
  end

  create_table "plutus_amounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "type"
    t.integer "account_id"
    t.integer "entry_id"
    t.decimal "amount", precision: 20, scale: 10
    t.integer "company_id"
    t.index ["account_id", "entry_id"], name: "index_plutus_amounts_on_account_id_and_entry_id"
    t.index ["company_id"], name: "index_plutus_amounts_on_company_id"
    t.index ["entry_id", "account_id"], name: "index_plutus_amounts_on_entry_id_and_account_id"
    t.index ["type"], name: "index_plutus_amounts_on_type"
  end

  create_table "plutus_entries", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "description"
    t.date "date"
    t.integer "commercial_document_id"
    t.string "commercial_document_type"
    t.string "slug"
    t.integer "company_id"
    t.boolean "is_system"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "is_show", default: false
    t.index ["commercial_document_id", "commercial_document_type"], name: "index_entries_on_commercial_doc"
    t.index ["company_id"], name: "index_plutus_entries_on_company_id"
    t.index ["date"], name: "index_plutus_entries_on_date"
    t.index ["slug"], name: "index_plutus_entries_on_slug", unique: true
  end

  create_table "product_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id"], name: "index_product_categories_on_company_id"
    t.index ["user_id"], name: "index_product_categories_on_user_id"
  end

  create_table "product_entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "category_id"
    t.integer "product_id"
    t.json "product_description"
    t.decimal "unit_price", precision: 18, scale: 2
    t.integer "no_of_unit"
    t.string "product_type"
    t.decimal "mrp", precision: 18, scale: 2
    t.decimal "discount", precision: 18, scale: 2
    t.decimal "total", precision: 30, scale: 2
    t.integer "company_id"
    t.integer "user_id"
    t.boolean "is_processed", default: false
    t.string "availablity", default: "available"
    t.decimal "old_unit_price", precision: 20, scale: 2
    t.string "slug"
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "item_profit", precision: 12, scale: 2
    t.boolean "is_returned", default: false
    t.string "return_remarks"
    t.integer "old_order_id"
    t.integer "returned_qty"
    t.boolean "is_sold", default: false
    t.date "expired_date"
    t.decimal "net_unit_price", precision: 16, scale: 2, default: "0.0"
    t.decimal "gst", precision: 16, scale: 2, default: "0.0"
    t.decimal "p_unit_price_with_discount", precision: 16, scale: 2, default: "0.0"
    t.index ["company_id", "user_id", "category_id"], name: "index_product_entries_on_company_id_and_user_id_and_category_id"
    t.index ["is_sold"], name: "index_product_entries_on_is_sold"
    t.index ["old_order_id"], name: "index_product_entries_on_old_order_id"
    t.index ["order_id"], name: "index_product_entries_on_order_id"
    t.index ["product_type"], name: "index_product_entries_on_product_type"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "unit"
    t.string "hsn_sac"
    t.text "description"
    t.integer "company_id"
    t.integer "user_id"
    t.bigint "product_category_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "gst"
    t.string "part_no"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
  end

  create_table "promoters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "total_shares", precision: 18, scale: 2
    t.decimal "nominal_value", precision: 10, scale: 2
    t.date "allotment_date"
    t.integer "reference_type"
    t.string "transaction_type"
    t.string "payment_mode"
    t.string "bank_name"
    t.string "cheque_no"
    t.string "utr_no"
    t.boolean "is_processed", default: false
    t.boolean "is_cheque", default: false
    t.integer "payment_ledger_id"
    t.string "payment_status"
    t.decimal "amount", precision: 18, scale: 2
    t.integer "created_by"
    t.string "slug"
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_id"], name: "index_promoters_on_company_id"
    t.index ["slug"], name: "index_promoters_on_slug", unique: true
    t.index ["user_id"], name: "index_promoters_on_user_id"
  end

  create_table "record_fixed_assets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "no_of_unit"
    t.decimal "unit_amount", precision: 20, scale: 2
    t.string "assets_type"
    t.boolean "is_returned", default: false
    t.bigint "fixed_asset_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "refrence_id"
    t.index ["fixed_asset_id"], name: "index_record_fixed_assets_on_fixed_asset_id"
  end

  create_table "returned_products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "quantity"
    t.string "remarks"
    t.integer "return_order_entry_id"
    t.bigint "product_entry_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_entry_id"], name: "index_returned_products_on_product_entry_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "roles_users", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id"
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id"
  end

  create_table "sale_service_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.decimal "amount", precision: 16, scale: 2
    t.decimal "total", precision: 16, scale: 2
    t.string "service_type"
    t.bigint "sale_service_id", null: false
    t.bigint "order_id", null: false
    t.integer "khatabook_id"
    t.boolean "is_processed", default: false
    t.integer "company_id"
    t.integer "user_id"
    t.string "status"
    t.date "t_date"
    t.decimal "gst", precision: 16, scale: 2, default: "0.0"
    t.index ["order_id"], name: "index_sale_service_transactions_on_order_id"
    t.index ["sale_service_id"], name: "index_sale_service_transactions_on_sale_service_id"
  end

  create_table "sale_services", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "slug"
    t.decimal "gst", precision: 10, scale: 2
    t.boolean "is_active", default: true
    t.integer "company_id"
    t.integer "user_id"
    t.index ["slug"], name: "index_sale_services_on_slug", unique: true
  end

  create_table "sold_products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "product_entries_id", null: false
    t.integer "sold_count", default: 0
    t.string "order_type"
    t.string "entry_type"
    t.integer "product_id"
    t.decimal "purchase_unit_price", precision: 10, scale: 2
    t.decimal "mrp", precision: 30, scale: 2, default: "0.0"
    t.decimal "sale_unit_price", precision: 10, scale: 2, default: "0.0"
    t.integer "company_id"
    t.datetime "transaction_date", precision: nil
    t.boolean "is_active", default: true
    t.integer "order_id"
    t.decimal "net_unit_price", precision: 16, scale: 2, default: "0.0"
    t.integer "returned_entry_id"
    t.decimal "sale_net_unit_price", precision: 16, scale: 2, default: "0.0"
    t.integer "category_id"
    t.index ["company_id"], name: "index_sold_products_on_company_id"
    t.index ["entry_type"], name: "index_sold_products_on_entry_type"
    t.index ["order_type"], name: "index_sold_products_on_order_type"
    t.index ["product_entries_id"], name: "index_sold_products_on_product_entries_id"
    t.index ["product_id"], name: "index_sold_products_on_product_id"
    t.index ["sold_count"], name: "index_sold_products_on_sold_count"
  end

  create_table "state_gsts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "state_name"
    t.string "gst_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "f_name"
    t.string "l_name"
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.boolean "is_active"
    t.bigint "company_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "jti", null: false
    t.string "slug"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  create_table "vender_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "company_name"
    t.string "landline"
    t.string "mobile"
    t.string "full_address"
    t.string "pan"
    t.string "tan"
    t.string "gst"
    t.integer "company_id"
    t.string "client_type"
    t.bigint "plutus_accounts_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["company_name"], name: "index_vender_details_on_company_name"
    t.index ["name"], name: "index_vender_details_on_name"
  end

  add_foreign_key "advance_salaries", "employees"
  add_foreign_key "advance_salary_payouts", "advance_salaries", column: "advance_salaries_id"
  add_foreign_key "employee_salary_transactions", "employee_salaries", column: "employee_salaries_id"
  add_foreign_key "employee_salary_transactions", "employees"
  add_foreign_key "expense_entries", "expense_categories"
  add_foreign_key "fixed_assets", "orders"
  add_foreign_key "khata_transactions", "khatabooks"
  add_foreign_key "orders", "khatabooks", column: "khatabooks_id"
  add_foreign_key "product_categories", "companies"
  add_foreign_key "product_categories", "users"
  add_foreign_key "product_entries", "orders"
  add_foreign_key "products", "product_categories"
  add_foreign_key "promoters", "companies"
  add_foreign_key "promoters", "users"
  add_foreign_key "record_fixed_assets", "fixed_assets"
  add_foreign_key "returned_products", "product_entries"
  add_foreign_key "sale_service_transactions", "orders"
  add_foreign_key "sale_service_transactions", "sale_services"
  add_foreign_key "sold_products", "product_entries", column: "product_entries_id"
  add_foreign_key "users", "companies"
end

class CreateSaleServiceTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :sale_service_transactions do |t|
      t.decimal :amount, precision: 16, scale: 2
      t.decimal :s_gst, precision: 10, scale: 2
      t.decimal :c_gst, precision: 10, scale: 2
      t.decimal :i_gst, precision: 10, scale: 2
      t.decimal :total, precision: 16, scale: 2
      t.string :service_type
      t.references :sale_service, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :khatabook_id
      t.boolean :is_processed, default: false
      t.integer :company_id
      t.integer :user_id
      t.string :status, default: "null"
      t.date :t_date
    end
  end
end

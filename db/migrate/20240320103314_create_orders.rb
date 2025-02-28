class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.json :paid_from
      t.date :order_date
      t.string :order_type
      t.integer :reference_type
      t.string :vechile_no
      t.string :mobile_no
      t.string :ack_no
      t.string :irn_no
      t.integer :company_id
      t.integer :user_id
      t.decimal :cgst, precision: 10, scale: 2
      t.decimal :sgst, precision: 10, scale: 2
      t.decimal :igst, precision: 10, scale: 2
      t.decimal :discount, precision: 10, scale: 2
      t.decimal :grand_total, precision: 18, scale: 2
      t.decimal :gst_paid, precision: 10, scale: 2
      t.decimal :gst_payble, precision: 10, scale: 2
      t.string  :slug
      t.string  :invoice_no
      t.boolean :auto_approved
      t.boolean :occupied, default: false
      t.decimal :order_profit, precision: 10, scale: 2 ,default: 0
      t.boolean :is_processed,  default: false
      t.references :khatabooks, null: false, foreign_key: true
      t.timestamps
    end

    add_index :orders, [:company_id, :user_id]
    add_index :orders, [:occupied]
  end
end

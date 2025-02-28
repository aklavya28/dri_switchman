class CreateSoldProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :sold_products do |t|
      t.references :product_entries, null: false, foreign_key: true
      t.integer :sold_count, default: 0
      t.string :order_type  # sale, purchase, sale return , purchase return
      t.string :entry_type # return, expired, Destroyed, sold,
      t.integer :product_id
      t.decimal :purchase_unit_price, precision: 10, scale: 2
      # t.timestamps
    end
  end
end

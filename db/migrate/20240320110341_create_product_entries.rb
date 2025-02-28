class CreateProductEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :product_entries do |t|
      t.integer :category_id
      t.integer :product_id
      t.json  :product_description
      t.decimal :unit_price, precision: 18, scale: 2
      t.integer :no_of_unit
      t.string :product_type
      t.decimal :mrp, precision: 18, scale: 2 # per unit
      t.decimal :discount, precision: 18, scale: 2 # per unit
      t.decimal :s_gst, precision: 18, scale: 2 # per unit
      t.decimal :c_gst, precision: 18, scale: 2 # per unit
      t.decimal :i_gst, precision: 18, scale: 2 # per unit
      t.decimal :total, precision: 18, scale: 2 # per unit
      t.integer :company_id
      t.integer :user_id
      t.boolean :is_processed, default: false
      t.string :availablity, :default => "available"
      t.decimal :old_unit_price, precision: 10, scale: 2
      t.string  :slug
      t.references :order, null: false, foreign_key: true
      t.timestamps
    end
    add_index :product_entries, [:company_id, :user_id, :category_id]
    add_index :product_entries, [:product_type]
  end
end

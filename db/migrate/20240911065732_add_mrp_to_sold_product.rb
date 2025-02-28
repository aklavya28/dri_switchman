class AddMrpToSoldProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :sold_products, :mrp, :decimal,precision: 10, scale: 2, default: 0
    add_column :sold_products, :sale_unit_price, :decimal,precision: 10, scale: 2, default: 0
    add_column :sold_products, :company_id, :integer
    add_index :sold_products, :order_type
    add_index :sold_products, :entry_type
    add_index :sold_products, :sold_count
    add_index :sold_products, :product_id
    add_index :sold_products, :company_id
  end
end

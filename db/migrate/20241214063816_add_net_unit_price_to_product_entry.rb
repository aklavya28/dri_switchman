class AddNetUnitPriceToProductEntry < ActiveRecord::Migration[7.0]
  def change
    add_column :product_entries, :net_unit_price, :decimal ,precision: 16, scale: 2, default: 0
    add_column :sold_products, :net_unit_price, :decimal ,precision: 16, scale: 2, default: 0
  end
end

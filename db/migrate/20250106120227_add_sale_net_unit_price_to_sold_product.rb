class AddSaleNetUnitPriceToSoldProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :sold_products, :sale_net_unit_price, :decimal ,precision: 16, scale: 2, default: 0
    add_column :product_entries, :p_unit_price_with_discount, :decimal ,precision: 16, scale: 2, default: 0
    change_column_default :orders, :is_returned, false

  end
end

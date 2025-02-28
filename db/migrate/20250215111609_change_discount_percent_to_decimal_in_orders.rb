class ChangeDiscountPercentToDecimalInOrders < ActiveRecord::Migration[7.0]
  def change
    change_column :orders, :discount_percent, :decimal, precision: 5, scale: 2, default: 0
  end
end

class AddDiscountPercentToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :discount_percent, :float, default: 0
    add_column :orders, :status, :string, default: "order_not_approve"
  end
end

class AddOrderIdToSoldProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :sold_products, :order_id, :integer
  end
end

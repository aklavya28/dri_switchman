class AddIsReturnedToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :is_returned, :boolean
    add_column :orders, :parent_order_id, :integer
    add_index :orders, :is_returned
  end
end

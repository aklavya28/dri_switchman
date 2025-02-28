class AddIsSoldToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :product_entries, :is_sold, :boolean, default: false
    add_column :product_entries, :expired_date, :date
    add_index :product_entries, :is_sold
  end
end

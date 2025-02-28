class AddOldCgstToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :old_cgst, :decimal, precision: 10, scale: 2
    add_column :orders, :old_sgst, :decimal, precision: 10, scale: 2
    add_column :orders, :old_igst, :decimal, precision: 10, scale: 2
    add_column :product_entries, :old_cgst, :decimal, precision: 10, scale: 2
    add_column :product_entries, :old_sgst, :decimal, precision: 10, scale: 2
    add_column :product_entries, :old_igst, :decimal, precision: 10, scale: 2
  end
end

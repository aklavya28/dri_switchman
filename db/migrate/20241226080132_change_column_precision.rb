class ChangeColumnPrecision < ActiveRecord::Migration[7.0]
  def change
    change_column :orders, :grand_total, :decimal, precision: 30, scale: 2
    change_column :orders, :gst_paid, :decimal, precision: 20, scale: 2
    change_column :orders, :gst_payble, :decimal, precision: 20, scale: 2
    change_column :orders, :order_profit, :decimal, precision: 20, scale: 2

    change_column :product_entries, :old_unit_price, :decimal, precision: 20, scale: 2
    change_column :product_entries, :total, :decimal, precision: 30, scale: 2

    change_column :sold_products, :mrp, :decimal, precision: 30, scale: 2

  end
end

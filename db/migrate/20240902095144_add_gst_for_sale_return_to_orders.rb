class AddGstForSaleReturnToOrders < ActiveRecord::Migration[7.0]
  def change

    add_column :orders, :gst_for_sale_return,  :decimal ,precision: 14, scale: 2, default: 0
  end
end

class UpdateGstToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :is_igst, :boolean, default: false
    remove_column :orders, :gst_for_sale_return, :decimal
    remove_column :orders, :cgst, :decimal
    remove_column :orders, :sgst, :decimal
    remove_column :orders, :igst, :decimal
    remove_column :orders, :old_cgst, :decimal
    remove_column :orders, :old_igst, :decimal
    remove_column :orders, :old_sgst, :decimal
    remove_column :orders, :freight_amount, :decimal
    remove_column :orders, :freight_charges, :json
    remove_column :orders, :freight_remarks, :string

    # product_entries
    add_column :product_entries, :gst, :decimal ,precision: 16, scale: 2, default: 0
    remove_column :product_entries, :c_gst, :decimal
    remove_column :product_entries, :i_gst, :decimal
    remove_column :product_entries, :s_gst, :decimal
    remove_column :product_entries, :old_cgst, :decimal
    remove_column :product_entries, :old_igst, :decimal
    remove_column :product_entries, :old_sgst, :decimal
    # sale_service_transactions
    add_column :sale_service_transactions, :gst, :decimal ,precision: 16, scale: 2, default: 0
    remove_column :sale_service_transactions, :c_gst, :decimal
    remove_column :sale_service_transactions, :i_gst, :decimal
    remove_column :sale_service_transactions, :s_gst, :decimal
  end
end

class AddFreightChargesToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :freight_charges, :json
    add_column :orders, :freight_remarks, :string
    add_column :orders, :freight_amount, :decimal ,precision: 10, scale: 2

  end
end

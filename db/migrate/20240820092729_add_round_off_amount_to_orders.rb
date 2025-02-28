class AddRoundOffAmountToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :round_off_amount,  :decimal ,precision: 6, scale: 2, default: 0
  end
end

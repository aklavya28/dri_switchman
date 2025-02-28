class AddItemProfitToProductEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :product_entries, :item_profit, :decimal , precision: 12, scale: 2
  end
end

class AddIsReturnedToProductEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :product_entries, :is_returned, :boolean, default:false
    add_column :product_entries, :return_remarks, :string
    add_column :product_entries, :old_order_id, :integer
    add_column :product_entries, :returned_qty, :integer
    add_index :product_entries, :old_order_id
  end
end

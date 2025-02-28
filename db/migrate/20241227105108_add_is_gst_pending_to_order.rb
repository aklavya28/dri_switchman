class AddIsGstPendingToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :is_gst_pending, :boolean, default: false
  end
end

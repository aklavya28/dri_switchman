class AddGstToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :gst, :integer
  end
end

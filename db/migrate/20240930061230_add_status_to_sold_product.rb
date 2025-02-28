class AddStatusToSoldProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :sold_products, :is_active, :boolean, default: true
  end
end

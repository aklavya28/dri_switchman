class AddCategoryIdToSoldProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :sold_products, :category_id, :integer
  end
end

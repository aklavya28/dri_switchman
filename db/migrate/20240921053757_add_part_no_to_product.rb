class AddPartNoToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :part_no, :string
  end
end

class AddHsnToFixedAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :fixed_assets, :hsn, :string
  end
end

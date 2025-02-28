class AddRefrenceIdToRecordFixedAsset < ActiveRecord::Migration[7.0]
  def change
    add_column :record_fixed_assets, :refrence_id, :integer
  end
end

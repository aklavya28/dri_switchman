class CreateRecordFixedAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :record_fixed_assets do |t|
      t.integer :no_of_unit
      t.decimal :unit_amount, precision: 20, scale: 2
      t.string :assets_type
      t.boolean :is_returned, default: false
      t.references :fixed_asset, null: false, foreign_key: true

      t.timestamps
    end
  end
end

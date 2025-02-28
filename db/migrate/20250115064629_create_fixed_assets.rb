class CreateFixedAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :fixed_assets do |t|
      t.string :name
      t.string :assets_type
      t.integer :no_of_unit
      t.decimal :unit_amount, precision: 20, scale: 2
      t.decimal :total, precision: 20, scale: 2
      t.decimal :gst, precision: 5, scale: 2
      t.decimal :gst_amount, precision: 20, scale: 2
      t.string :slug
      t.references :order, null: false, foreign_key: true
      t.timestamps
    end

  end
end

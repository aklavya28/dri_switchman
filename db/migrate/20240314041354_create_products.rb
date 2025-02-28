class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :unit
      t.string :hsn_sac
      t.text :description
      t.integer :company_id
      t.integer :user_id
      t.references :product_category, null: false, foreign_key: true

      t.timestamps
    end
  end
end

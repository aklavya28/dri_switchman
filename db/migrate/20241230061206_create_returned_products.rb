class CreateReturnedProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :returned_products do |t|
      t.integer :quantity
      t.string :remarks
      t.integer :return_order_entry_id
      t.references :product_entry, null: false, foreign_key: true
      t.timestamps
    end
    # remove_column :product_entries, :remarks, :string
    add_column :sold_products, :returned_entry_id, :integer
  end
end

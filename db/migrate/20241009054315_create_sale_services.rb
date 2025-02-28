class CreateSaleServices < ActiveRecord::Migration[7.0]
  def change
    create_table :sale_services do |t|
      t.string :name,  unique: true
      t.string :description
      t.string :slug
      t.decimal :gst, precision: 10, scale: 2
      t.boolean :is_active, default: true
      t.integer :company_id
      t.integer :user_id

      # t.timestamps
    end
    add_index :sale_services, :slug, unique: true
  end
end

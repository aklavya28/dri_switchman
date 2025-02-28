class CreateVenderDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :vender_details do |t|
      t.string :name
      t.string :company_name
      t.string :landline
      t.string :mobile
      t.string :full_address
      t.string :pan
      t.string :tan
      t.string :gst
      t.integer :company_id
      t.string :client_type

      # t.references :plutus_accounts, null: false, foreign_key: true
      t.bigint :plutus_accounts_id, null: false
      # t.references(:plutus_accounts)

      t.timestamps
    end
    add_index :vender_details, :company_name
    add_index :vender_details, :name
  end
end

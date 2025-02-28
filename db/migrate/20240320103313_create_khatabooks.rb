class CreateKhatabooks < ActiveRecord::Migration[7.0]
  def change
    create_table :khatabooks do |t|
      t.string :name
      t.string :company_name
      t.string :pan
      t.string :tan
      t.string :address
      t.string :gst
      t.string :mobile
      t.string :email
      t.string :account_type
      t.boolean :is_active, default: true
      t.string  :slug
      t.integer :plutus_ledger_id
      t.integer :company_id
      t.integer :user_id

      t.timestamps
    end
    add_index :khatabooks, [:slug, :company_id]
    add_index :khatabooks, [:pan], unique: true

    # add_index :khatabooks, :slug
    # add_index :khatabooks, :company_id
    # add_index :khatabooks, :pan, unique: true
  end
end

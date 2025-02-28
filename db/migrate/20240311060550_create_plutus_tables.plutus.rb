# This migration comes from plutus (originally 20160422010135)
class CreatePlutusTables < ActiveRecord::Migration[4.2]
  def change
    create_table :plutus_accounts do |t|
      t.string  :name
      t.string  :type
      t.boolean :contra, default: false
      t.integer :company_id
      t.string  :slug
      t.integer :code
      t.boolean :is_system
      t.integer :group_id
      t.boolean :is_depreciated
      t.boolean :show_in_daybook

      t.timestamps


    end
    add_index :plutus_accounts, :slug, unique: true
    add_index :plutus_accounts, :code, unique: true
    add_index :plutus_accounts, :company_id
    add_index :plutus_accounts, [:name, :type]

    create_table  :plutus_entries do |t|
      t.string    :description
      t.date      :date
      t.integer   :commercial_document_id
      t.string    :commercial_document_type
      t.string    :slug, unique: true
      t.integer   :company_id
      t.boolean   :is_system

      t.timestamps
    end
    add_index :plutus_entries, :slug, unique: true
    add_index :plutus_entries, :company_id
    add_index :plutus_entries, :date
    add_index :plutus_entries, [:commercial_document_id, :commercial_document_type], :name => "index_entries_on_commercial_doc"

    create_table  :plutus_amounts do |t|
      t.string      :type
      t.references  :account
      t.references  :entry
      t.decimal     :amount, :precision => 20, :scale => 10
      t.integer     :company_id
    end
    add_index :plutus_amounts, :company_id
    add_index :plutus_amounts, :type
    add_index :plutus_amounts, [:account_id, :entry_id]
    add_index :plutus_amounts, [:entry_id, :account_id]
  end
end

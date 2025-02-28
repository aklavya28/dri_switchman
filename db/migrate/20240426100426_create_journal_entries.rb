class CreateJournalEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :journal_entries do |t|
      t.string :entry_type
      t.string :entry_account_type
      t.integer :plutus_account_id
      t.text :remarks
      t.decimal :amount, precision: 18, scale: 2
      t.string :payment_mode
      t.string :utr,unique: true
      t.date :transfer_date
      t.string :transfer_mode
      t.string :bank_name
      t.string :cheque_no
      t.date :cheque_date
      t.date :entry_date
      t.boolean :is_processed, default: false
      t.string :slug
      t.bigint :company_id
      t.bigint :user_id
      t.timestamps
    end
  end
end

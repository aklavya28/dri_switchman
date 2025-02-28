class CreateExpenseEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :expense_entries do |t|
      t.string :remarks
      t.decimal :amount, precision: 15, scale: 2, default: 0
      t.integer :payment_ledger_id
      t.references :expense_category, null: false, foreign_key: true, index: true
      t.string :slug,  index: true, unique: true
      t.date :transaction_date
      t.integer :company_id, index: true
      t.boolean :is_processed, default: false
      t.integer :user_id
      # t.timestamps
    end
  end
end

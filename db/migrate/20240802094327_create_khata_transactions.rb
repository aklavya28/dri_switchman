class CreateKhataTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :khata_transactions do |t|

      t.json :paid_to
      t.string :remarks
      t.string :payment_type
      t.date :transaction_date
      t.decimal :amount, precision: 10, scale: 2
      t.boolean :is_processed, default: false
      t.references :khatabook, null: false, foreign_key: true
      t.integer :user_id
      t.integer :company_id
      t.string :slug
      t.timestamps
    end
  end
end

class CreatePromoters < ActiveRecord::Migration[7.0]
  def change
    create_table :promoters do |t|
      t.decimal :total_shares, precision: 18, scale: 2
      t.decimal :nominal_value, precision: 10, scale: 2
      t.date :allotment_date
      t.integer :reference_type
      t.string :transaction_type
      t.string :payment_mode
      t.string :bank_name
      t.string :cheque_no
      t.string :utr_no, unique: true
      t.boolean :is_processed, default: false
      t.boolean :is_cheque, default: false
      t.integer :payment_ledger_id
      t.string :payment_status
      t.decimal :amount, precision: 18, scale: 2
      t.integer :created_by
      t.string :slug
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.timestamps
    end
    add_index :promoters, :slug, unique: true
  end
end

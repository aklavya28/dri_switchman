class CreateAdvanceSalaries < ActiveRecord::Migration[7.0]
  def change
    create_table :advance_salaries do |t|

      t.integer :tenure
      t.decimal :amount, precision: 10, scale: 2
      t.references :employee, null: false, foreign_key: true
      t.integer :payment_ledger_id
      t.integer :company_id
      t.integer :user_id
      t.string :slug
      t.boolean :is_payout, default: false #for checking payout is done not used
      t.boolean :is_processed, default: false
      t.boolean :is_paid, default: false

      t.timestamps
    end
    add_index :advance_salaries, :slug
  end
end

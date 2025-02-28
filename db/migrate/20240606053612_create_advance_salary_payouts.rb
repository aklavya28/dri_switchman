class CreateAdvanceSalaryPayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :advance_salary_payouts do |t|

      t.decimal :amount, precision: 10, scale: 2
      t.boolean :is_paid, default: false
      t.string :trn_type
      t.integer :emp_id
      t.references :advance_salaries, null: false, foreign_key: true
      t.integer :company_id
      t.timestamps
    end
  end
end

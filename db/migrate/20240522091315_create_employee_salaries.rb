class CreateEmployeeSalaries < ActiveRecord::Migration[7.0]
  def change
    create_table :employee_salaries do |t|
      t.date :salary_date
      t.decimal :allowances, precision: 12, scale: 2
      t.json :allowances_breack_up
      t.decimal :deductions, precision: 12, scale: 2
      t.decimal :installment, precision: 10, scale: 2
      t.json :installment_breckup
      t.string :installment_ids
      t.json :deductions_breack_up
      t.decimal :net_salaries, precision: 18, scale: 2
      t.decimal :gross_salaries, precision: 18, scale: 2
      t.string :slug
      t.string :payment_type
      t.integer :cr_ledger_id
      t.integer :company_id
      t.integer :user_id
      t.boolean :is_processed, default: false
      t.timestamps
    end
    add_index :employee_salaries, :slug
    add_index :employee_salaries, :company_id
  end
end

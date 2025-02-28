class CreateEmployeeSalaryTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :employee_salary_transactions do |t|

      t.decimal :allwance, precision: 12, scale: 2
      t.decimal :deduction, precision: 12, scale: 2
      t.decimal :installment, precision: 10, scale: 2
      t.decimal :net_salary, precision: 18, scale: 2
      t.decimal :gross_salary, precision: 18, scale: 2
      t.json :break_up
      t.string :slug
      t.references :employee, null: false, foreign_key: true
      t.references :employee_salaries, null: false, foreign_key: true
      t.integer :company_id
      t.integer :user_id

      t.timestamps
    end
    add_index :employee_salary_transactions, :company_id

  end
end

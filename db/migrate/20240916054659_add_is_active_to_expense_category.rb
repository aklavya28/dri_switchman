class AddIsActiveToExpenseCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :expense_categories, :is_active, :boolean, default: true
  end
end

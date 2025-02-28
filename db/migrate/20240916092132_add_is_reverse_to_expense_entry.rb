class AddIsReverseToExpenseEntry < ActiveRecord::Migration[7.0]
  def change
    add_column :expense_entries, :is_reversed, :boolean, default: false
    add_column :expense_entries, :reverse_id, :integer
  end
end

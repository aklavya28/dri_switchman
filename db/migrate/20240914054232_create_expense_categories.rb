class CreateExpenseCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :expense_categories do |t|
      t.string :name, unique: true, index: true
      t.integer :user_id
      t.integer :company_id, index: true
      # t.timestamps
    end

  end
end

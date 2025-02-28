class AddTransactionDateToSoldProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :sold_products, :transaction_date, :datetime
  end
end

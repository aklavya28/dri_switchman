class AddTempBalanceToPlutusAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :plutus_accounts, :temp_balance, :decimal ,precision: 18, scale: 2, default: 0
    # add_column :plutus_accounts, :temp_balance, :string
  end
end

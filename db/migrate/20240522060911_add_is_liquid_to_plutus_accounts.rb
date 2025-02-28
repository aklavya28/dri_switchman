class AddIsLiquidToPlutusAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :plutus_accounts, :is_liquid, :boolean, default: false
    add_column :plutus_accounts, :is_bank, :boolean, default: false
    add_column :plutus_accounts, :is_lender, :boolean, default: false
    add_column :plutus_accounts, :user_id, :integer
  end
end

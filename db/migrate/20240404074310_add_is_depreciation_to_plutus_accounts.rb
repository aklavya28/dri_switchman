class AddIsDepreciationToPlutusAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :plutus_accounts, :is_depreciation, :boolean
    add_column :plutus_accounts, :depreciation_type, :string
  end
end

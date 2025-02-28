class AddkhtaTypeToKhatabook < ActiveRecord::Migration[7.0]
  def change
    add_column :khatabooks, :khata_type, :string
    add_column :khatabooks, :ledger_name, :string
    remove_column :khatabooks, :dr_number, :string
    remove_column :khatabooks, :cr_number, :string
    remove_column :khatabooks, :is_creditor, :boolean
    remove_column :khatabooks, :is_debtor, :boolean
  end
end

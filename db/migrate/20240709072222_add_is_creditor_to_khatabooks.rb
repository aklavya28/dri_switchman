class AddIsCreditorToKhatabooks < ActiveRecord::Migration[7.0]
  def change
    add_column :khatabooks, :is_creditor, :boolean, default: false
    add_column :khatabooks, :is_debtor, :boolean,  default: false
    add_column :khatabooks, :aadhar, :string
    add_column :khatabooks, :dr_number, :string
    add_column :khatabooks, :cr_number, :string
    # Remove the unique constraint from `name`
    remove_index :khatabooks, :pan, unique: true
    # add_index :khatabooks, :pan
     # Remove the `description` column
    remove_column :khatabooks, :account_type, :string
    add_index :khatabooks, :is_creditor
    add_index :khatabooks, :is_debtor
    add_index :khatabooks, :cr_number
    add_index :khatabooks, :dr_number
  end
end

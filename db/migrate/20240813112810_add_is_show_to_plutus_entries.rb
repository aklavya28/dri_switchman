class AddIsShowToPlutusEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :plutus_entries, :is_show, :boolean, default: :false
  end
end

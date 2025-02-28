class AddIsReverseToEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :is_reverse, :boolean, default: false
  end
end

class CreateEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :entries do |t|
      t.date    :entry_date
      t.string  :narration
      t.text    :entry_info
      t.string  :slug
      t.boolean :is_processed, default: false
      t.integer :company_id
      t.integer :user_id
      t.timestamps
    end
  end
end

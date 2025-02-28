class CreateBanks < ActiveRecord::Migration[7.0]
  def change
    create_table :banks do |t|
      t.string :bank_name
      t.string :ac_holder_name
      t.string :ac_number
      t.string :ifsc
      t.integer :company_id
      t.integer :user_id
      t.string :slug
      t.timestamps
    end
  end
end

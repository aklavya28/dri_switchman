class CreateCompanyLogins < ActiveRecord::Migration[7.0]
  def change
    create_table :company_logins do |t|
      t.string :company_name
      t.string :database
      t.timestamps
    end
  end
end

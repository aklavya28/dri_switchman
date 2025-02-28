class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :full_name
      t.string :fathername
      t.string :mobile
      t.string :email
      t.date :dob
      t.date :joining_date
      t.string :full_address
      t.string :aadhaar
      t.string :pan
      t.string :designation
      t.string :job_type
      t.string :nominee_name
      t.string :relation_with_nominee
      t.string :nominee_address
      t.string :nominee_mobile
      t.json :salary_settings
      t.boolean :is_active
      t.integer :user_id
      t.integer :company_id
      t.timestamps
    end
    add_index :employees, :full_name
    add_index :employees, :mobile, unique: true
    add_index :employees, :email, unique: true

  end
end

class AddSlugToEmployees < ActiveRecord::Migration[7.0]
  def change
    add_column :employees, :slug, :string, unique: true
  end
end

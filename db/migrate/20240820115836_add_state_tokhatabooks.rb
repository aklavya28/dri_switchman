class AddStateTokhatabooks < ActiveRecord::Migration[7.0]
  def change
    add_column :khatabooks, :state_id, :integer
  end
end

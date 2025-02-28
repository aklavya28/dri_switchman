class AddStateToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :state_gst_id, :bigint
  end
end

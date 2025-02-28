class CreateStateGsts < ActiveRecord::Migration[7.0]
  def change
    create_table :state_gsts do |t|
      t.string :state_name
      t.string :gst_code
      t.timestamps
    end
  end
end

class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|

      t.string  :logo
      t.string  :name
      t.text    :description
      t.string  :phone
      t.text    :address
      t.boolean :active
      t.string  :contact_email
      t.string  :contact_number
      t.string  :domain_name
      t.string  :account_number
      t.string  :ifsc
      t.string  :upi_id
      t.date    :incorporation_date
      t.string  :incorporation_country
      t.string  :incorporation_state
      t.string  :incremental_share_certificate_no
      t.decimal :application_fee, precision: 10, scale: 2
      t.decimal :authorised_capital, precision: 18, scale: 2
      t.decimal :paid_up_capital, precision: 18, scale: 2
      t.decimal :nominal_value, precision: 18, scale: 2
      t.string  :pan_no
      t.string  :tan_no
      t.string  :cin_no
      t.string  :gst_no
      t.boolean :under_maintenance

      t.timestamps
    end
  end
end

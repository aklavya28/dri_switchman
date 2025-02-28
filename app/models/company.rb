class Company < ApplicationRecord
  has_many :users
  belongs_to :state_gst

  # Company.create_new_company
  def self.create_new_company

    data =  self.create(
      name: 'Dev Rising Industries',
      description: "An auto repair workshop",
      phone: "9459538312",
      address: "PO - Ghanahatti, teh/Distt - Shimla, 171011",
      active: 1,
      contact_email: "testing@testing.com",
      contact_number: "9999911111",
      domain_name: "dri.com",
      account_number: "39735247446" ,
      ifsc: "SBIN0013703",
      upi_id: "devnidhi@sbi",
      incorporation_date: "2022-06-27",
      incorporation_country: "india",
      incorporation_state: "Himachal Pradesh",
      incremental_share_certificate_no: "2825828582",
      application_fee: "50000",
      authorised_capital: "500000".to_f.round(2),
      paid_up_capital: "10000000".to_f.round(2),
      nominal_value: nil,
      pan_no: "CATPB4112R",
      tan_no: "PTLD14632C",
      cin_no: "U67110HP2019PLC007512",
      gst_no: "02AAHCD3160AIZH",
      under_maintenance: 0,

    )
    return puts data


  end
end

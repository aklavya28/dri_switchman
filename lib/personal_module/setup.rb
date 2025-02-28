module PersonalModule::Setup
  #PersonalModule::Setup.state_with_gst_code
  #PersonalModule::Setup.create_new_company
  #User.admin_user(1, "Sunil", "Bhardwaj", "admin@admin.com", "admin@admin.com")
  #PersonalModule::Setup.setup_new_company_ledger( company_id = 1)
  #PersonalModule::Setup.user_role_tb

  def self.state_with_gst_code
    STATE_GST.each do |s|
    @state =  StateGst.new()
     @state.state_name = s[:state_name]
     @state.gst_code = s[:gst_code]
    @state.save!
    end
     puts "done"
  end
  #PersonalModule::Setup.create_new_company
  def self.create_new_company
    data =  Company.create(
      name: 'Dev Rising Industries',
      description: "An auto repair workshop",
      phone: "9459538312",
      address: "PO - Ghanahatti, teh/Distt - Shimla, 171011",
      state_gst_id: 2,
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
  # ======================================================
  # create adming user

  # User.admin_user(company_id, f_name, l_name, email, pass)
  # e.g  User.admin_user(2, "Sunil", "Bhardwaj", "admin@admin.com", "admin@admin.com")
  # ======================================================
    # create roles
    # PersonalModule::Setup.user_role_tb
    def self.user_role_tb
      role = []
      ROLE.each do |r|
        role << r
        Role.find_or_create_by!(name: r)
      end
      return puts role
    end

  # ======================================================

  # PersonalModule::Setup.setup_new_company_ledger( company_id = 1)

  # @@asset = ["cash_book", "bank_book", "purchase_order", "gst_paid"].freeze
  # @@equity = ["promoters"].freeze
  # @@liability = ["gst_payble", "sale_order"].freeze
  @@ledgers ={
    :Asset =>["cash_book", "store", "gst_paid", "advance_salary", "fixed_assets"],
    :Equity => ["promoters"],
    :Liability => ["gst_payble", "pf", "employer_pf" ],
    :Revenue =>["service_charges_revenue", "sales_revenue","purchase_discount"],
    :Expense =>["company_expenses", "salary", "service_expense", "cost_of_goods_sold","order_round_off", "loss_on_sale_of_fixed_assets"]
  }
  # PersonalModule::Setup.setup_new_company_ledger( company_id = 1)
  def self.setup_new_company_ledger( company_id = 1)
    @@ledgers.as_json.each do |i, v|
      # puts "I: #{i}, v:#{v}"
      v.each do |l|
         create_ledgers(l, "Plutus::#{i}", company_id)
        # puts "ladger #{l}"
      end
    end

    # create_ledgers(data, ladger_type)
    # @@asset.each do |l|
    #   @ledger = Plutus::Account.all
    #   @ledger.present? ? code = @ledger.last.code.to_f.round(0)+1 : code = 101
    #   @duplicate = Plutus::Account.find_by_name("#{l}_#{company_id}")
    #   unless (@duplicate.present?)
    #     if(l == 'purchase_order')
    #       Plutus::Asset.find_or_create_by!(:name => "#{l}_#{company_id}", :company_id => company_id, :code => code, :is_depreciation => 1, :depreciation_type => "Sum of years digits ");
    #     else
    #       Plutus::Asset.find_or_create_by!(:name => "#{l}_#{company_id}", :company_id => company_id, :code => code);
    #     end
    #   end
    #   puts "#{l}"
    # end
    # @@equity.each do |l|
    #   @ledger = Plutus::Account.all
    #   @ledger.present? ? code = @ledger.last.code.to_f.round(0)+1 : code = 101

    #   @duplicate = Plutus::Account.find_by_name("#{l}_#{company_id}")
    #   unless (@duplicate.present?)
    #     Plutus::Equity.find_or_create_by!(:name => "#{l}_#{company_id}", :company_id => company_id, :code => code);
    #   end
    # end
  end

  private
  def self.create_ledgers(l, ladger_type, company_id)
    # return puts "d: #{data}"
    # puts "data #{data} l: #{ladger_type}"
    # data.each do |l|
      @ledger = Plutus::Account.all
      @ledger.present? ? code = @ledger.last.code.to_f.round(0)+1 : code = 101

      @duplicate = ladger_type.constantize.find_by_name("#{l}_#{company_id}")
      unless (@duplicate.present?)
        if(l == 'purchase_order')
          ladger_type.constantize.find_or_create_by!(:name => "#{l}_#{company_id}", :company_id => company_id, :code => code, :is_depreciation => 1, :depreciation_type => "Sum of years digits",is_system: true);
        elsif(l == 'cash_book')
          ladger_type.constantize.find_or_create_by!(:name => "#{l}_#{company_id}", :company_id => company_id, :code => code, :is_liquid => true,is_system: true);
        else
          ladger_type.constantize.find_or_create_by!(:name => "#{l}_#{company_id}", :company_id => company_id, :code => code,is_system: true);
        end
      end
      puts "done #{l}"
    # end
  end

end

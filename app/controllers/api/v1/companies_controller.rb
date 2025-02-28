
class Api::V1::CompaniesController < ActionController::API
  require 'pagy/extras/array'
  include Pagy::Frontend
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :account_params, only: [:create]
  before_action :find_user, only: [:index]

  def product_units
    if PRODUCT_UNITS.present?
      render json: { message: "loaded successfully", data:  PRODUCT_UNITS }, status: :ok
    else
      render json: { error: "Something want wrong" }, status: 401
    end
  end

  def index

    if(@user && @user.company)
        render json: { message: "Company profile loaded successfully", data:  @user.company }, status: :ok
      else
        render json: { error: "Something want wrong" }, status: 204
    end
  end
  def create_user
    begin
      @user =  User.new( params.fetch(:data, {}).permit!)
      @user.password = "12345678"
      @user.email = params[:data]["email"].downcase
      @user.is_active = true
      @user.company_id = current_user.company_id
      @user.save!
      render json: { message: "User created successfully!", data: @user }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Somthing want wrong", err_message: e.record.errors.full_messages }, status: 422
    end
  end
  def get_users
    @company = Company.find_by_id(current_user.company_id)

    if (@company.present?)
      @users =  @company.users
        render json: { message: "Success", data: @users }, status: :ok
      else
        render json: { error: "Somthing want wrong" }, status: 204
    end
  end
  def get_roles
      @roles = Role.where.not(name: "SuperAdmin")
    if(@roles.present?)
        render json: { message: "Success", data: @roles }, status: :ok
    else
       render json: { err_message: "Somthing want wrong", error: app.errors.full_messages }, status: 401
    end
  end
  def set_roles
    if(params[:user_id].present? && params[:role_id].present?)

     @roled =  User.find_by_id(params[:user_id]).roles.where(id: params[:role_id])
     if( @roled.present?)
      return render json: { err_message: "Already #{@roled.first.name}" }, status: 401
     end

      @userrole = User.find_by_id(params[:user_id]).roles << Role.find(params[:role_id])
      if(@userrole)
        render json: { message: "Success", data: @userrole }, status: :ok and return
        else
          render json: { err_message: "Somthing want wrong", error: app.errors.full_messages }, status: 401 and return
      end
      else
        render json: { err_message: "Somthing want wrong", error: app.errors.full_messages }, status: 401 and return
    end
  end
  def assign_roles

    begin
      @user = User.find_by(slug: params[:user_slug])

    if @user.present?
      params[:roles].each do |r|
        RolesUser.find_or_create_by!(user_id: @user.id, role_id: r)
      end

      # delete unwanted roles
      old_role =[]
      @user.roles.each do |r|
        old_role << r.id
      end
      curruent_role = params[:roles]
      both_ides = curruent_role + old_role
      grouped = both_ides.group_by { |element| element }
      result = grouped.select { |key, value| value.size == 1 }.keys

      if result.present?
        result.each do |id|
          RolesUser.where(user_id: @user.id, role_id: id).delete_all
        end
      end
      # return render json:

      # delete unwanted roles
      render json: { message: "Success", data: @user.roles}, status: :ok and return
      else
        render json: { message: "Somthing want wrong"}, status: 401 and return
    end
    rescue StandardError => e
      render json: { err_message: "Somthing want wrong", error: e.message}, status: 401 and return
    end

  end
  def get_user_associated_roles
  #  return render json:  params[:slug]
   @user = User.find_by(slug: params[:slug] )
    if@user.present?
      @roles = RolesUser.where(user_id: @user.id)
      data =[]
      if(@roles.present?)
        @roles.each do |role|
          data << role.role_id
        end
      end
      render json: { message: "Success", data:  data}, status: :ok and return
      else
        render json: { message: "Role not found", data:[]}, status: :ok and return
    end
  end

  # Api::V1::CompaniesController.get_ledgers
  # def self.get_ledgers
  def get_ledgers

    testing = []
    type = Plutus::Account.where(company_id: current_user.company_id).group(:type).count;
    # type = Plutus::Account.where(company_id: 2).group(:type).count;
    type.each do |key|
      ledgers_f = Plutus::Account.where(type: key, company_id: current_user.company_id, group_id: nil).each {|l| l.name = (l.name.delete_suffix("_#{current_user.company_id}").upcase.split('_').join(" "))}
      ledgers = ledgers_f.dup
      # ledgers = Plutus::Account.where(type: key, company_id: 2).each {|l| l.name = (l.name.delete_suffix("_#{2}").upcase.split('_').join(" "))}
      # return puts key.first.constantize
      if key[0] == 'Plutus::Asset'
        name = "Debitors"
        temp_balance = []
        Plutus::Account.where(type: key, company_id: current_user.company_id, group_id: 1).each  do |l|
          temp_balance << l.balance.to_f
        end
        ledgers  << {name: name, temp_balance:  temp_balance.length > 0 ? temp_balance.sum : 0}
      elsif key[0] == 'Plutus::Liability'

        name = "Creditors"
        temp_balance = []
        Plutus::Account.where(type: key, company_id: current_user.company_id, group_id: 2).each  do |l|
          temp_balance << l.balance.to_f
        end
        ledgers  << {name: name, temp_balance:  temp_balance.length > 0 ? temp_balance.sum : 0}
      end
      # return render json: {name: name, temp_balance:  temp_balance.length > 0 ? temp_balance.sum : 0}

      tral_bal = key.first.constantize.where(company_id:current_user.company_id).balance.to_f
      testing <<  {name: key.first.delete_prefix('Plutus::'), count: key.last, ledgers: ledgers, balance: tral_bal}
    end
    # return puts testing
    if(testing.length > 0)
      render json: { message: "Success", data: testing}, status: :ok and return
    else
        render json: { err_message: "Somthing want wrong" }, status: 401 and return
    end
  end
  def get_ledgers_by_name
    name = params[:name]
    ac =   Plutus::Account.where("name LIKE ? AND company_id =?", "%#{name}%", current_user.company_id)
    .select("name, type as lType, slug")
    .each do |l|
      l.name = (l.name.delete_suffix("_#{current_user.company_id}").upcase.split('_').join(" "))
      l.lType = (l.lType.delete_prefix("Plutus::").upcase)
    end
    if(ac.length > 0)
      render json: { message: "Success", data: ac}, status: :ok and return
    else
        render json: { err_message: "Ledger not found. Please check spelling" }, status: 401 and return
    end
  end
  def refresh_ledgers
   Plutus::Account.where(company_id:current_user.company_id).each do |l|
      bal = Plutus::Account.find_by_id(l.id).balance.to_f
      l.update(temp_balance: bal)
   end
   render json: { message: "Success"}, status: :ok and return
  end

  def company_bank_account
    @duplicate =  Bank.where( company_id: current_user.company_id, bank_name: params[:bank]['bank_name'])
    Bank.where( company_id: 1, bank_name: "xyz").count
    if(@duplicate.count == 0)
      @bank = Bank.new(params.fetch(:bank, {}).permit!)
      @bank.user_id = current_user.id
      @bank.company_id = current_user.company_id
      if(@bank.save!)
        @l_bank  = "#{params[:bank]['bank_name'].downcase.split(' ').join('_')}_#{current_user.company_id}"
        @ledger = Plutus::Account.all
        @ledger.present? ? code = @ledger.last.code.to_f.round(0)+1 : code = 101
        # @ac = Plutus::Asset.find_or_create_by!(:name => @l_bank, :company_id => current_user.company_id, :code => code, :is_liquid => true, :is_bank => true);
        @ac = Plutus::Asset.find_or_create_by!(:name => @l_bank, :company_id => current_user.company_id, :is_liquid => true, :is_bank => true);
        render json: { message: "Successfully Created", data: @bank, ac:@ac   }, status: :ok
      else
        render json: { err_message: "Somthing want wrong", error: app.errors.full_messages }, status: 401
      end
      else

        render json: { err_message: "Duplicate bank account" }, status: 401
    end
  end
  def update_company_bank_account
    @bank = Bank.find_by_slug(params[:bank][:slug])
    @update =  @bank.update(params.fetch(:bank, {}).permit!)
    if(@update)
      render json: { message: "Success", data: @update }, status: :ok
    else
      render json: { err_message: "Somthing want wrong" }, status: 401
    end
  end
  def get_company_banks
    # return render json: params
  # def show
       @banks = Bank.where(company_id: current_user.company_id)
      if (@banks.present?)
        render json:{ status: "data", data: @banks }, status: 200 and return
      else
        render json: { error: "Somthing want wrong" }, status: 204 and return
      end
  end
  def get_ledger_detail
    begin
      items_per_page = 100
      page = params[:page].present? ?  params[:page].to_i : 1
      # end_date = params[:end_date].to_datetime
      # start_date = params[:start_date].to_datetime > end_date || params[:start_date].to_datetime == end_date ? end_date-2.month : params[:start_date].to_datetime
      # @data = Entry.where(company_id: current_user.company_id, entry_date: (start_date.to_date)..end_date.to_date).order(id: :desc)
      if params[:start_date] == 'undefined'
        start_date = Company.first.incorporation_date
        end_date = Date.today()
        # query = { date: start_date..end_date}
      else
        end_date = params[:end_date].to_datetime
        start_date = params[:start_date].to_datetime
        # query = {date: start_date.to_date..end_date.to_date}
      end
      if params[:slug].downcase == 'debitors'
        m = query_getting_ledger_entries("Debitors", 1, start_date.to_date,end_date.to_date)
        @data =  m[:data]
        name = m[:name]
        balance = m[:balance]
      elsif  params[:slug].downcase == 'creditors'
        m = query_getting_ledger_entries("Creditors", 2, start_date.to_date,end_date.to_date)
        @data =  m[:data]
        name = m[:name]
        balance = m[:balance]
      else
        ac = Plutus::Account.find_by_slug(params[:slug])
        tempname = ac.name.split("_")
        name = tempname.take(tempname.size - 1).join(" ").upcase
        @data = Plutus::Amount.where(account_id: ac.id).select(:id,:type, :amount)
        .joins(:entry)
        .where("plutus_entries.date BETWEEN ? AND ?", start_date.to_date,end_date.to_date)
        .select("commercial_document_type,description, date, slug, is_show, type as t")
        .order( "plutus_entries.date DESC")
          balance = ac.balance
      end
      @pagy, entries = pagy(@data, items: items_per_page, page: page)
      render json:{ status: "Bind Successfully", data: entries, balance: balance, name: name, pagination: @pagy,start:entries.last.date , end:entries.first.date }, status: 200 and return
    rescue Pagy::OverflowError
      @pagy, entries = pagy(@data, items: items_per_page, page: 1)
      params[:page] = @pagy.last
      retry
    end
  end
  def query_getting_ledger_entries(name, group_id, start_date, end_date)
      @data = Plutus::Amount.select(:id,:type, :amount)
        .joins(:entry, :account)
        .where("plutus_entries.date BETWEEN ? AND ?", start_date.to_date,end_date.to_date)
        .where("plutus_accounts.group_id =?", group_id)
        .select("plutus_entries.commercial_document_type,plutus_entries.description, plutus_entries.date, plutus_entries.slug, plutus_entries.is_show, plutus_amounts.type as t")
        .order( "plutus_entries.date DESC")
        @name = "#{name}"
        balance = Plutus::Account.where(group_id: group_id).map{|t| t.balance}.sum.to_f
        return {
          data: @data,
          balance: balance,
          name: @name
        }
  end


  def get_entry_detail
    @acc = []
   entry = Plutus::Entry.find_by_slug(params[:slug])
   data = Plutus::Amount.where(entry_id: entry.id).select(:amount, :type).joins(:account).select(:name)
    new_data = data.as_json( methods: :type)
    # return render json: new_data[0]['name']
    new_data.each do |trns|
      d = trns['name'].split("_")
      name = d.take(d.count - 1).join(" ").upcase
      @acc << { :name => name, :amount => trns['amount'].to_f, :type => trns['type'] }
    end
    if(@acc.present?)
      render json:{ status: "Bind Successfully", data:@acc }, status: 200 and return
    else
      render json: { error: "Somthing want wrong" }, status: 401 and return
    end
  end
  private

  def account_params
     params.fetch(:company, {}).permit!
  end

  def find_user
    @user = User.find_by_id(current_user.id)
  end
end

class Api::V1::KhatabooksController < ApplicationController
  before_action :authenticate_user!
  require 'json'
  require 'pagy/extras/jsonapi'
  include Pagy::Backend
  def get_all_khatabooks
    begin
      items_per_page = 50
      params[:page].present? &&  params[:page].to_i != 0 ? page = params[:page].to_i : page=  1
      if params[:search] != 'undefined'
        search = JSON.parse(params[:search])
        # return render  json: search["search_by"]
        case search["search_by"]
            when "name"
              @data = Khatabook.where("company_id =? AND name LIKE ?", current_user.company_id,"%#{search["name"]}%").where.not(name: "System Khata").order(id: :desc)
            when "mobile"
              @data = Khatabook.where("company_id =? AND mobile LIKE ?", current_user.company_id,"%#{search["mobile"]}%").where.not(name: "System Khata").order(id: :desc)
            when "ac"
              @data = Khatabook.where("company_id =? AND dr_number LIKE ? OR cr_number LIKE ?", current_user.company_id,"%#{search["ac"]}%", "%#{search["ac"]}%").where.not(name: "System Khata").order(id: :desc)
        end
      else
          @data = Khatabook.where(company_id: current_user.company_id).where.not(name: "System Khata").order(id: :desc)
      end
      @pagy, @paginated_khatabook  = pagy(@data, items: items_per_page, page:page)
      @khatabook = @paginated_khatabook.map do |d|
        # return render  json:  Plutus::Account.find_by_name("#{d.ledger_name}").balance.to_f.round(2)
          balance = Plutus::Account.find_by_name("#{d.ledger_name}").nil? ? 0 : Plutus::Account.find_by_name("#{d.ledger_name}").balance.to_f.round(2)
          d.as_json.merge({
            "balance": balance,
            "orders": d.orders.count,
            "l_name": d.ledger_name.split("_")[0..-2].join(" ")
          })
      end
      if @khatabook.present?
        render json:{ status: "Bind Successfully", data: @khatabook, pagination: @pagy }, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 401 and return
      end
    rescue Pagy::OverflowError
      @pagy, @khatabook = pagy(@data, items: items_per_page, page:1)
      params[:page] = @pagy.last
      retry
    end
  end

  def get_all_khatabooks_drop
    # return render json: params[:type] == "debtor"
    if params[:type] == "debtor"
      #  return render json:  "debtor"
      @khatabook = Khatabook.where(company_id: current_user.company_id, khata_type: "debtor",  is_active: true).where.not(name: "System Khata").order(name: :desc)
    elsif params[:type] == "creditor"
      # return render json:  "creditor"
      @khatabook = Khatabook.where(company_id: current_user.company_id,khata_type: "creditor", is_active: true).where.not(name: "System Khata").order(name: :desc)
    else
      @khatabook = Khatabook.where(company_id: current_user.company_id, is_active: true).where.not(name: "System Khata").order(name: :desc)
    end
    render json:{  status: "khatabook load Successfully", data: @khatabook}, status: 200 and return

  end




  def create
    begin
      # return render  json: {data: params}, status: 401
      ActiveRecord::Base.transaction do
        mobile = Khatabook.where(mobile: params[:data][:mobile], company_id: current_user.company_id)
        if mobile.present?
          render json: { error: "Mobile number already exists"}, status: 401 and return
        end
        last_temp = Khatabook.last
        last_id = last_temp.nil? ? 1 : last_temp.id + 1
        ledger_name = (params[:data][:name]).to_s.downcase.split(" ").join("_")
        @newkhata = Khatabook.new( params.fetch(:data, {}).except(:account_type).permit!)
        @newkhata.company_id = current_user.company_id
        @newkhata.ledger_name = "#{ledger_name}_#{last_id}"
        @newkhata.user_id = current_user.id
        if @newkhata.save!
          # return render json: account_no
          if(@newkhata.khata_type.downcase == 'debtor')
            Plutus::Asset.create!(name: "#{@newkhata.ledger_name}",company_id: current_user.company_id, user_id: current_user.id,is_system: true,  group_id: 1)
          else
            Plutus::Liability.create!(name: "#{@newkhata.ledger_name}",company_id: current_user.company_id,user_id: current_user.id,is_system: true, group_id: 2)
          end
        else
            raise ActiveRecord::Rollback
        end
      end
      render json:{  status: "khatabook Created Successfully", data: @newkhata}, status: 200 and return
    rescue => e
      # Handle any exceptions

      message ="We're sorry, but your khata could not be register at this time. Please try again later or contact support if the issue persists."
      return render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end

  end


  # def change_active_status_khata
  def update
    @emp =  Khatabook.find_by(slug: params[:slug])
    if( @emp.present?)
      @emp.update(is_active: params[:is_active])
      if(@emp)
        render json:{ status: "Status chaned successfully", data: @emp  }, status: 200 and return
      else
          render json: { error: "Somthing want worng!" }, status: 401 and return
      end
    else
        render json: { error: "No Employee found" }, status: 401 and return
    end

  end
  def get_all_lenders
  # return render json: params
    #  @lander = Khatabook.where(company_id: current_user.company_id, account_type: params[:type].present? ? "creditor" : "debtor" ).order(name: :asc)
    if params[:type].present? && params[:type] == "creditor"
      @lander = Khatabook.where(company_id: current_user.company_id, is_creditor: true, is_active: true ).order(name: :asc)
    else
      @lander = Khatabook.where(company_id: current_user.company_id, is_debtor: true, is_active: true ).order(name: :asc)
    end
    if @lander.present?
      render json:{  status: "khatabook load Successfully", data: @lander}, status: 200 and return
    else
        render json: { error: "Data not found"}, status: 401 and return
    end
  end


  def get_states
    @state = StateGst.all
    state_id = current_user.company.state_gst_id
    if @state.present?
      render json:{  status: "States loaded Successfully", data: @state, state_id:state_id}, status: 200 and return
    else
        render json: { error: "Data not found"}, status: 401 and return
    end
  end

  # def khata_profile

  #   items_per_page = 2
  #   params[:page].present? ? page = params[:page] : page=  1

  #   @khata =  Khatabook.find_by_slug(params[:slug])
  #    if @khata.present?
  #     acc = Plutus::Account.find_by_name("#{ @khata.ledger_name}")
  #     data = Plutus::Amount
  #             .where(account_id: acc.id)
  #             .select(:description, :date, :is_show, :type)
  #             .joins(:entry)
  #             .select(:id,:type,:slug, :amount)
  #             .order( created_at: :desc)

  #           # return render  json: data.length
  #             # page.to_i > (data.length/items_per_page ).to_i ? page = 1 : page


  #             pagy, entries = pagy(data, items: items_per_page, page:page)



  #     render json:{ status: "Bind Successfully", data: entries.as_json( methods: :type), balance: acc.balance,  pagination: pagy }, status: 200 and return
  #     # render json:{ status: "Bind Successfully", data: entries.as_json( methods: :type), ac_info: ac_data, pagination: pagy }, status: 200 and return
  #       #  render json:{ status: "Bind Successfully", data: entries.as_json( methods: :type), balance: balance, name: name, pagination: pagy }, status: 200 and return

  #    else
  #       render json: { error: "Data not found"}, status: 401 and return
  #    end



  # end
  def khata_profile
    # Default items per page and page number
    items_per_page = 100
    page = params[:page].present? ? params[:page].to_i : 1

    # Find the khatabook
    @khata = Khatabook.find_by(slug: params[:slug])

    if @khata.present?
      acc = Plutus::Account.find_by(name: @khata.ledger_name)

      if acc.present?
        data = Plutus::Amount
               .where(account_id: acc.id)
               .joins(:entry)
               .select(:id, :type, :slug, :amount, :description, :date, :is_show)
               .order(created_at: :desc)

        # Safe pagination with error handling
        begin
          pagy, entries = pagy(data, items: items_per_page, page: page)

          render json: {
            status: "Bind Successfully",
            data: entries.as_json(methods: :type),
            balance: acc.balance,
            pagination: pagy
          }, status: :ok

        rescue Pagy::OverflowError => e
          render json: {
            error: "Page out of range. Valid range: 1 - #{e.pagy.pages}",
            total_pages: e.pagy.pages
          }, status: :bad_request
        rescue StandardError => e
          Rails.logger.error("Pagination Error: #{e.message}")
          render json: { error: "An unexpected error occurred" }, status: :internal_server_error
        end
      else
        render json: { error: "Account not found" }, status: :not_found
      end
    else
      render json: { error: "Khatabook not found" }, status: :not_found
    end
  end


  def get_khata
    khata = Khatabook.find_by_slug(params[:slug])
    if khata.present?
      @acc=[]
      Plutus::Account.where(is_liquid: true, company_id: current_user.company_id).each do |ac|
        d = ac.name.split("_")
        name = d.take(d.count - 1).join(" ")
        balance = Plutus::Account.find_by_name(ac.name).balance.to_f.round(2)
        @acc << {:id=> ac.id, :name => name, orginal_name: ac.name,is_bank: ac.is_bank, :balance =>balance }
      end
      render json:{ status: "Bind Successfully", liquid: @acc, khata_balance: Plutus::Account.find_by_name(khata.ledger_name).balance}, status: 200 and return

    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end


end

class Api::V1::KhataTransactionsController < ApplicationController
  require 'json'
  require 'pagy/extras/jsonapi'
  before_action :authenticate_user!
  def index
    items_per_page = 100
    params[:page].present? ? page = params[:page] : page=  1

    @khata  = Khatabook.find_by_slug(params[:slug]).khata_transactions.order(id: :desc)
    # pagy, @khatabook  = pagy(Khatabook.where(company_id: current_user.company_id).order(id: :desc),page: page, items:per_page_records)
    if(@khata.present?)
      # render json:{  status: "khata Transactions loaded Successfully", data: @khata}, status: 200 and return

      pagy, entries = pagy(@khata, items: items_per_page, page:page)
      render json:{ status: "Bind Successfully", data: entries, pagination: pagy }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
    # return render json: @khata

  end

  def create
    begin
      ActiveRecord::Base.transaction do
        # return render json: {data: params}, status: 401
        @khata = Khatabook.find_by_slug(params[:data][:slug])
        @amount = 0
        params[:data][:paid_to].each {|t| @amount += t["value"].to_f}
        @data =  @khata.khata_transactions.new(khata_params)
        @data.amount = @amount
        @data.user_id = current_user.id
        @data.company_id = current_user.company_id

        if @data.save!
          Accounting::Khatabook.approve_khata_transaction(@data.id)
        end
        unless @data
          raise ActiveRecord::Rollback
        end
      end
      render json:{  status: "khata Transactions #{@data.payment_type.upcase} Successfully", balance: Plutus::Account.find_by_name( @khata.ledger_name).balance}, status: 200 and return
    rescue => e
      # Handle any exceptions
      message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity

    end
  end
  def khata_orders
    # return render json:   params[:form_data] == 'undefined'
    form = JSON.parse(params[:form_data])  if params[:form_data] != 'undefined'

    items_per_page = 100
    params[:page].present? ? page = params[:page] : page=  1
    if (form.present?)
      if  form["seach_value"].present?
        @khata  = Khatabook.find_by_slug(params[:slug]).orders.where(order_type: ["debit","credit"])
        .where("#{form["search_by"]} LIKE ?", "%#{form["seach_value"]}%")
        .order(order_date: :desc)
      elsif  form["end"].present? && !form["order_type"].present?
        @khata  = Khatabook.find_by_slug(params[:slug]).orders.where(order_type: ["debit","credit"])
        .where( order_date: (form["start"].to_date)+1.day..(form["end"].to_date)+1.day)
        .order(order_date: :desc)
      elsif  form["order_type"].present?
        case  form["order_type"]
        when "purchase"
            query = "order_type = 'debit' AND is_returned IS NULL OR is_returned = false "
        when "purchase_return"
            query = "order_type = 'credit' AND is_returned = true "
        when "sale"
            query = "order_type = 'credit' AND is_returned IS NULL OR is_returned = false "
        when "sale_return"
            query = "order_type = 'debit' AND is_returned = true"
        when "not_approved"
            query = "order_type IN ('debit', 'credit') AND auto_approved = false"
        end
        @khata  = Khatabook.find_by_slug(params[:slug]).orders
        .where(query)
        .where( order_date: (form["start"].to_date)+1.day..(form["end"].to_date)+1.day)
        .order(order_date: :desc)
      else
        @khata  = Khatabook.find_by_slug(params[:slug]).orders.where(order_type: ["debit","credit"]).order(order_date: :desc)
      end
    else
      @khata  = Khatabook.find_by_slug(params[:slug]).orders.where(order_type: ["debit","credit"]).order(order_date: :desc)
    end



    # pagy, @khatabook  = pagy(Khatabook.where(company_id: current_user.company_id).order(id: :desc),page: page, items:per_page_records)
    if(@khata.present?)
      # render json:{  status: "khata Transactions loaded Successfully", data: @khata}, status: 200 and return

      pagy, entries = pagy(@khata, items: items_per_page, page:page)
      render json:{ status: "Bind Successfully", data: entries, pagination: pagy }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end



  def destroy
    begin
      ActiveRecord::Base.transaction do
        id = params[:id]
        trans = KhataTransaction.find_by_id(id)

        if trans.present?
          @entry = Plutus::Entry.where(commercial_document_id: id, commercial_document_type: "KhataTransaction").first

          if @entry.present?
            @entry.amounts.destroy_all if @entry.amounts.present?
            @entry.destroy
          end
          trans.destroy

        else
          render json: { error: "Transaction not found" }, status: :not_found and return
        end
      end
      render json: { status: "Khata Transaction Deleted Successfully" }, status: :ok and return
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be deleted at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end

  private
  def khata_params
     params.fetch(:data, {}).except(:slug).permit!
  end



end

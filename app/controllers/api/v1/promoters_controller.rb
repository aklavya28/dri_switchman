class Api::V1::PromotersController < ApplicationController
  before_action :authenticate_user!
  def promoter_as_user
    # return render json: params
      @newuser = User.new
      @newuser.f_name = params[:f_name].capitalize
      @newuser.l_name = params[:l_name].capitalize
      @newuser.email = params[:email].downcase
      @newuser.password = params[:password]
      @newuser.company_id = params[:company_id]
      @newuser.is_active = true

      @newuser.save
      if(@newuser.save)
        role = Role.find_by_id(3)
        @newuser.roles << role
        render json: { message: "Promoter saved successfully", data: @newuser }, status: :ok
        else
          errors = @newuser.errors.full_messages
          render json: { error: errors }, status: 401
      end

  end
  def index

      comp_id = current_user.company_id

      @users  = User.where(company_id: comp_id).joins(:roles).where(roles: {id: 3}).group(:email)
      if @users.present?
      #  return render json: @user
       @share_price = SHARE_PRICE
      render json: { message: "Success", data: @users, share: @share_price }, status: :ok
      else
        errors = @users.errors.full_messages
        render json: { error: errors }, status: 401
    end
  end
  def create
    # Company.where(id: current_user.company_id)
    # return render json: params
    @auth_cap = Company.find_by_id(current_user.company_id).authorised_capital.to_f.round(2)
    @avail_bal =  Promoter.balance_available(current_user.company_id)

    if((params[:total_shares].to_f.round(0) * params[:nominal_value].to_f.round(2)) > ( @auth_cap - @avail_bal))
      return render json: {status: 401, err_message:" Unauthorized Purchase. The total number of shares requested exceeds the authorized capital of the company. "}, status: :unauthorized
    end
    if params[:paymentdetail][:payment_mode] =='cheque'
    end

    @promoter = Promoter.new(promoter_params)
    @promoter.is_processed = false
    @promoter.cheque_no = params[:paymentdetail][:cheque_no]
    @promoter.bank_name = params[:paymentdetail][:name_of_bank]
    @promoter.payment_mode = params[:paymentdetail][:payment_mode]
    @promoter.utr_no = params[:paymentdetail][:utr_no]
    @promoter.reference_type = 1

    @promoter.amount = params[:total_shares].to_f.round(0) * params[:nominal_value].to_f.round(2)
    # paymnet details
    if params[:paymentdetail][:payment_mode] =='cheque'
      @promoter.transaction_type = "c pending"
      @promoter.payment_status = "pending"
      else
        @promoter.transaction_type = "credit"
        @promoter.payment_status = "success"
    end
    # paymnet details

    @promoter.save
    if(@promoter.save)
      unless  params[:paymentdetail][:payment_mode] =='cheque'
        Company.where(id: current_user.company_id ).first.update(paid_up_capital: (@avail_bal + @promoter.amount.to_f.round(2)) )
      end
      return render json: { message: "Successfully Alloated", data: @promoter }, status: :ok
      else
        return render json: {status: 401, err_message:"error "}
    end
  end

  def promoters_with_share
    @promoters =  User.select('users.id, COUNT(promoters.user_id) AS transaction_count, SUM(promoters.total_shares) AS shares, SUM(promoters.total_shares * promoters.nominal_value) AS total_value, users.email, CONCAT(users.f_name, " ", users.l_name) AS fullname, users.slug')
    .where(company_id: current_user.company_id)
    .joins(:promoters)
    .merge(Promoter.not_allocated)
    .group('users.id')

    if(@promoters.present?)
      total_value=0
      @promoters.each {|val| total_value += (val.total_value).to_f.round(0)}
      render json:{ status: "Data fetched successfully", data: @promoters, total_value: total_value}, status: 200 and return
      else
        render json: { err_message: "no data found" }, status: 204 and return
    end

    # return render json:  params
  end
  def show
      begin
        @user =  User.find_by_slug(params[:id])
        if(@user.present? && @user.promoters.present?)
            total_amt =  @user.promoters.balance_available(current_user.company_id)
            render json:{ status: "success dfsd", data: @user.promoters, total_value: total_amt}, status: 200 and return
        else
          render json: { err_message: "User or promoters not found" }, status: :not_found
        end
      rescue => exception
        Rails.logger.error("Error fetching user: #{exception.message}")
        render json: { err_message: "Something went wrong", error: exception.message }, status: :internal_server_error
      end
  end
  # new methods form user component
  def current_share_price
      return render json: SHARE_PRICE
  end

  def add_shares_to_promoter
    begin
      ActiveRecord::Base.transaction do
       @user_id = User.find_by_slug(params[:promoter_slug]).id
          if( @user_id.present?)
            @shares =  Promoter.new( params.fetch(:data, {}).permit!)
            @shares.user_id =  @user_id
            @shares.created_by =  current_user.id
            @shares.company_id =  current_user.company_id
            @shares.transaction_type =  "credit"
            @shares.payment_status =  params[:data][:is_cheque]? "pending" : "success"

            if @shares.save!
              @accounting = Accounting::Share.promoter_share(@shares)

            else
              render json: { error: "Something went wrong" }, status: 401 and return
            end
          else
              render json: { error: "Something went wrong" }, status: 401 and return
          end
      end
        render json:{ status: "Order Placed Successfully", data: @shares }, status: 200 and return
    rescue => e
      # Handle any exceptions

      message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end

  end
  # new methods form user component









  private
  def promoter_params
     params.fetch(:promoter, {}).permit!
  end



end

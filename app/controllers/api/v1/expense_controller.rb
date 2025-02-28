class Api::V1::ExpenseController < ApplicationController
  require 'json'
  require 'pagy/extras/jsonapi'
  include Pagy::Backend
  before_action :authenticate_user!
  def get_expense_category

   @data = ExpenseCategory.where(company_id: current_user.company_id, is_active:true)
    if @data.present?
    render json:{ status: "Bind Successfully", data: @data }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end
  def save_expense_entry
    begin
      ActiveRecord::Base.transaction do

        @entry = ExpenseEntry.new(expense_params)
        @entry.company_id = current_user.company_id
        @entry.user_id = current_user.id
        if  @entry.save!
          Accounting::Entry.process_expense_entry(@entry)
        end

        # unless @entry.save!
        #   render json: { error: "data not Saved", err_message: @entry.errors.full_messages }, status: 401 and return
        # end
      end
      render json: { status: "saved Successfully" }, status: :ok and return
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end
  def get_exp_entries
    # return render  json: params[:start_date]
    begin
      # end_date = params[:end_date].to_datetime
      # start_date = params[:start_date].to_datetime > end_date || params[:start_date].to_datetime == end_date ? end_date-2.month : params[:start_date].to_datetime
      items_per_page = 100
      params[:page].present? ? page = params[:page].to_i : page=  1

      if params[:start_date] == 'undefined'
        query = {company_id: current_user.company_id }
      else
        end_date = params[:end_date].to_datetime
        start_date = params[:start_date].to_datetime
        query = {company_id: current_user.company_id, date: start_date.to_date..end_date.to_date}
      end

      @data = ExpenseEntry
      .joins('JOIN expense_categories e ON expense_entries.expense_category_id = e.id')
      .select("expense_entries.*, e.name")
      .where(query)
      .order(transaction_date: :desc)

      if( @data.present?)
        @pagy, entries = pagy(@data, items: items_per_page, page:page)
        # return render json: pagy
        render json:{ status: "Bind Successfully", data: entries, pagination: @pagy, start:@data.last.transaction_date , end:@data.first.transaction_date   }, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 401 and return
      end
    rescue Pagy::OverflowError
      @pagy, entries = pagy(@data, items: items_per_page, page:1)
      params[:page] = @pagy.last
      retry
    rescue  => e
      render json: { error: "method error", e:e}, status: 401 and return
    end
  end
  def get_exp_categories
    @categories = ExpenseCategory.where(company_id: current_user.company_id).order(id: :desc)
    if  @categories.present?
      render json:{ status: "Bind Successfully", data: @categories }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end
  def change_active_exp_categories
    @cat =  ExpenseCategory.find_by_id(params[:id])
    if @cat.present?
      @cat.update(is_active: !@cat.is_active)
      render json:{ status: "Update Successfully", data: @cat }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end
  def save_expense_category
   @cat =   ExpenseCategory.where(name: (params[:data][:name]).strip, company_id: current_user.company_id)
   if @cat.present?
    render json: { error: "Duplicate Category Name"}, status: 401 and return
   end
    begin
      ActiveRecord::Base.transaction do
        @newcat =  ExpenseCategory.new(params.fetch(:data, {}).permit!)
        @newcat.company_id = current_user.company_id
        @newcat.user_id = current_user.id
        @newcat.save!
      end
      render json: { status: "saved Successfully" }, status: :ok and return
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end

  def reverse_exp_entry
    begin
      ActiveRecord::Base.transaction do
        slug = params[:slug]
        # slug = "c42775d1-f3b3-411f-8f8f-7bc351e67f08"
        old_expense = ExpenseEntry.find_by_slug(slug)

        new_exp = ExpenseEntry.new(old_expense.attributes.except("id", "is_reversed","remarks","reverse_id"))
        new_exp.is_reversed = true
        new_exp.remarks = "Reverse #{old_expense.remarks}"
        new_exp.reverse_id = old_expense.id
        new_exp.transaction_date = DateTime.now()
        new_exp.is_processed = false
        if new_exp.save!
          old_expense.update(is_reversed: true)
          Accounting::Entry.process_reverse_expense_entry(new_exp)
        end

    end
      render json: { status: "saved Successfully" }, status: :ok and return
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end

  private
  def expense_params
     params.fetch(:data, {}).except(:payment_ledger).permit!
  end
end

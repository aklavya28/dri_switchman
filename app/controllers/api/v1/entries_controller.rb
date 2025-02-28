class Api::V1::EntriesController < ApplicationController
  require 'json'
  require 'pagy/extras/jsonapi'
  before_action :account_params, only: [:create]
  before_action :authenticate_user!
  # before_action :permit_vender, only: [:create_ledger]

  def create_ledger

    begin
      ActiveRecord::Base.transaction do
        @name = params[:name].gsub(' ', '_').downcase
        @bane_result =   Plutus::Account.where(company_id: current_user.company_id, name:"#{@name}_#{current_user.company_id}").first
        if(!@bane_result)
          @code =   Plutus::Account.last.code.nil? ? 0 : Plutus::Account.last.code
          # return render json: "Plutus::#{params[:ladger_type]}"
          @data =  "Plutus::#{params[:type]}".constantize.create(:name => "#{@name}_#{current_user.company_id}", :company_id => current_user.company_id)
          # @data = Plutus::Account.find_by_id(5)
            unless @data.present?
              render json: { error: "ledger not Saved", err_message: @data.errors.full_messages }, status: 401 and return
            end
        else
          render json: { error: "Duplicate ledger name" }, status: 401 and return
        end
      end
    render json:{ status: "Ledger created Successfully", data: @data }, status: 200 and return
    rescue => e
      # Handle any exceptions

      message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
      # ensure
      #   # Cleanup code that runs whether or not the transaction is successful
      #   cleanup_task

    end
  end

  def get_ledgers_by_type
      @ledgers =    Plutus::Account.where(type: params[:type], company_id: current_user.company_id).select('id','name')
    if(@ledgers.present?)
     render json:{ status: "success", data: @ledgers }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end

  def get_list_of_banks
    @banks = APP_BANK_LIST
    if(@banks.present?)
      render json:{ status: "success", data: @banks }, status: 200 and return
     else
       render json: { error: "Data not saved"}, status: 401 and return
     end
  end

  def save_journal_entry
   data = params[:entry]
   @entry =  JournalEntry.new

    if(data[:common_data][:entry_account_type] == 'Plutus::Expense')
      entry_type = "credit"
    elsif(data[:common_data][:entry_account_type] == 'Plutus::Revenue')
      entry_type = "debit"
    else
      entry_type = "debit"
    end

   @entry.entry_type = entry_type
   @entry.entry_account_type = data[:common_data][:entry_account_type]
   @entry.plutus_account_id = data[:common_data][:plutus_account_id]
   @entry.remarks = data[:common_data][:remarks]
   @entry.amount = data[:common_data][:amount].to_f.round(2)
   @entry.payment_mode = data[:common_data][:payment_mode]
   @entry.utr = data[:bank_data][:utr]
   @entry.transfer_date = data[:bank_data][:transfer_date].to_date if data[:bank_data][:transfer_date].present?
   @entry.transfer_mode = data[:bank_data][:transfer_mode]
   @entry.bank_name = data[:cheque_data][:bank_name]
   @entry.cheque_no = data[:cheque_data][:cheque_no]
   @entry.cheque_date = data[:cheque_data][:cheque_date].to_date if data[:cheque_data][:cheque_date].present?
   @entry.entry_date = DateTime.now
   @entry.is_processed  = false
   @entry.company_id = current_user.company_id
   @entry.user_id =  current_user.id
   @entry.save!
   if(@entry.present?)
    render json:{ status: "success", data: @entry }, status: 200 and return
    else
    render json: { error: "Data not saved"}, status: 401 and return
   end

  end

  def get_all_ledgers
     @account =  []
     Plutus::Account.where(company_id: current_user.company_id).order(name: :asc).each do |n|
      d = n.name.split("_")
      name = d.take(d.count - 1).join(" ")
      @account << {name: name, id:n.id}
     end

    if(@account.present?)
        render json:{ status: "success", data: @account }, status: 200 and return
    else
        render json: { error: "no data"}, status: 401 and return
    end
  end
  def create_new_journal_entry

     @info = {debit: params[:data][:debit],credit: params[:data][:credit]}
     @entry = Entry.new
     @entry.entry_date =  params[:data][:date]
     @entry.narration =  params[:data][:narration]
     @entry.entry_info =  @info.to_json
     @entry.company_id =  current_user.company_id
     @entry.user_id =  current_user.id
     @entry.save!
     if(@entry.present?)

          comp_id = current_user.company_id
          debit = []
          credit = []

          JSON.parse(@entry.entry_info)["debit"].each do |d|
            # debit << {:account_name => Plutus::Account.find_by_id(d["ledger_name"].split(',')[0]).name,:amount => d["amount"], :company_id => comp_id }
            debit << {:account_name => Plutus::Account.find_by_id(d["id"]).name,:amount => d["amount"], :company_id => comp_id }
          end
          JSON.parse(@entry.entry_info)["credit"].each do |d|
            # credit << {:account_name => Plutus::Account.find_by_id(d["ledger_name"].split(',')[0]).name,:amount => d["amount"], :company_id => comp_id }
            credit << {:account_name => Plutus::Account.find_by_id(d["id"]).name,:amount => d["amount"], :company_id => comp_id }
          end
        @p_entry = Plutus::Entry.new(
          :description => @entry.narration,
          :date =>  @entry.entry_date,
          :commercial_document_type => JournalEntry,
          :commercial_document_id => @entry.id,
          :company_id => comp_id,
          :debits => debit,
          :credits => credit)
          @p_entry.save!
          if @p_entry.present?
            @entry.update(is_processed: true)
          end
        render json:{ status: "success", data: @p_entry }, status: 200 and return
      else
        render json: { error: "no data"}, status: 401 and return
     end
  end

  # def get_all_entries
  #   per_page_records = 100
  #   params[:page_no].present? ? page = params[:page_no] : page=  1
  #   all_entries = Entry.where(company_id: current_user.company_id).order(id: :desc)
  #   pagy, @entries  = pagy(all_entries,page: page, items:per_page_records)
  #  if @entries.present?

  #   # render json: { data:   @orders,
  #   #          links: pagy_jsonapi_links(pagy), status: "Orders load Successfully", balance: Order.balance_available }, status: 200 and return
  #     render json:{ total_pages: pagy.last, pagination: pagy, total_records: pagy.count, per_page_records: per_page_records, active_page: page, status: "Entries load Successfully", data: @entries}, status: 200 and return
  #   else
  #     render json: { error: "Data not found"}, status: 401 and return
  #   end
  # end
  def get_all_entries
    begin
      items_per_page = 100
      params[:page].present? ? page = params[:page].to_i : page=  1

      # end_date = params[:end_date].to_datetime
      # start_date = params[:start_date].to_datetime > end_date || params[:start_date].to_datetime == end_date ? end_date-2.month : params[:start_date].to_datetime

      if params[:start_date] == 'undefined'
        query = {company_id: current_user.company_id }
      else
        end_date = params[:end_date].to_datetime
        start_date = params[:start_date].to_datetime
        query = {company_id: current_user.company_id, entry_date: start_date.to_date..end_date.to_date}
      end


      @data = Entry.where(query).order(id: :desc)
      if( @data.present?)
        @pagy, entries = pagy(@data, items: items_per_page, page:page)
        # return render json: pagy
        render json:{ status: "Bind Successfully", data: entries, pagination: @pagy, start:entries.last.entry_date , end:entries.first.entry_date }, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 401 and return
      end
    rescue Pagy::OverflowError
      @pagy, entries = pagy(@data, items: items_per_page, page:1)
      params[:page] = @pagy.last
      retry
    end
  end
  def get_all_entries_plutus
    begin
      # return render  json: params[:start_date] == 'undefined'
      items_per_page = 100
      params[:page].present? ? page = params[:page].to_i : page=  1


      if params[:start_date] == 'undefined'
        query = {company_id: current_user.company_id }
      else
        end_date = params[:end_date].to_datetime
        start_date = params[:start_date].to_datetime
        query = {company_id: current_user.company_id, date: start_date.to_date..end_date.to_date}
      end
      @data = Plutus::Entry.where(query)
      # @data = Plutus::Entry.where(company_id: current_user.company_id, date: start_date.to_date..end_date.to_date)
      .joins(:amounts)
      .select("plutus_entries.*, SUM(plutus_amounts.amount) AS total_debits")
      .where(plutus_amounts: { type: "Plutus::DebitAmount" })
      .group("plutus_entries.id")
      .order("plutus_entries.date DESC")
      # .where("plutus_entries.date BETWEEN ? AND ?", start_date.to_date,end_date.to_date)
      #
      if( @data.present?)
        @pagy, entries = pagy(@data, items: items_per_page, page:page)
        # return render json: pagy
        render json:{ status: "Bind Successfully", data: entries, pagination: @pagy, start:@data.last.date , end:@data.first.date }, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 401 and return
      end
    rescue Pagy::OverflowError
      @pagy, entries = pagy(@data, items: items_per_page, page:1)
      params[:page] = @pagy.last
      retry
    rescue  => e
      render json: { error: "Data not found", e:e}, status: 401 and return
    end
  end
  def reverse_entry
    @entry = Entry.find_by_slug(params[:slug])
    if @entry.present?
      comp_id = current_user.company_id
      debit = JSON.parse(@entry.entry_info)["credit"]
      credit = JSON.parse(@entry.entry_info)["debit"]

      @revs_info =  '{'+'"debit"'+":#{debit.to_json},"+'"credit"'+":#{credit.to_json}"+'}'
      # return render json: @revs_info
     @revs_entry = Entry.new
     @revs_entry.entry_date =  DateTime.now
     @revs_entry.narration =  "Reverse trn_id:#{@entry.slug} :-  #{@entry.narration}"
     @revs_entry.entry_info =   @revs_info
     @revs_entry.company_id =  comp_id
     @revs_entry.user_id =  current_user.id
     @revs_entry.is_reverse =  true
     @revs_entry.save!

    #  return render json: @revs_entry.entry_info
      #  plutus
      if @revs_entry.present?
          @entry.update(is_reverse: true)

          comp_id = current_user.company_id
          revs_debit = []
          revs_credit = []
          JSON.parse(@revs_entry.entry_info)["debit"].each do |d|
            # revs_debit << {:account_name => Plutus::Account.find_by_id(d["ledger_name"].split(',')[0]).name,:amount => d["amount"], :company_id => comp_id }
            revs_debit << {:account_name => Plutus::Account.find_by_id(d["id"]).name,:amount => d["amount"], :company_id => comp_id }
          end
          JSON.parse(@revs_entry.entry_info)["credit"].each do |d|
            # revs_credit << {:account_name => Plutus::Account.find_by_id(d["ledger_name"].split(',')[0]).name,:amount => d["amount"], :company_id => comp_id }
            revs_credit << {:account_name => Plutus::Account.find_by_id(d["id"]).name,:amount => d["amount"], :company_id => comp_id }
          end
          @p_entry = Plutus::Entry.new(
            :description => @revs_entry.narration,
            :date =>  @revs_entry.entry_date,
            :commercial_document_type => Entry,
            :commercial_document_id => @revs_entry.id,
            :company_id => comp_id,
            :debits => revs_debit,
            :credits => revs_credit)
            @p_entry.save!
            if @p_entry.present?
              @revs_entry.update(is_processed: true)
            end
          render json:{ status: "success", data: @p_entry }, status: 200 and return
      end
    else
      render json: { error: "no data"}, status: 401 and return
    end
  end

  def promoter_params
    params.fetch(:promoter, {}).permit!
  end

 def permit_vender
    params[:vender].fetch(:vender_detail, {}).permit!
 end
end

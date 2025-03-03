class Api::V1::DashboardController < ApplicationController
  require 'json'
  require 'pagy/extras/jsonapi'
  include Pagy::Backend
  before_action :switch_tenant
  before_action :authenticate_user!
  def stock_register
    begin

      items_per_page = 100
      params[:page].present? ? page = params[:page].to_i : page=  1
      # return render  json: params
      # @data = SoldProduct
      query = SoldProduct
          .joins('JOIN products p ON sold_products.product_id = p.id')
          .select('p.name, p.unit, p.id')
          .select('SUM(CASE WHEN sold_products.entry_type = \'purchase\' THEN sold_products.sold_count ELSE 0 END) AS purchase_count')
          .select('SUM(CASE WHEN sold_products.entry_type = \'sale\' THEN sold_products.sold_count ELSE 0 END) AS sale_count')
          .select('SUM(CASE WHEN sold_products.entry_type = \'sale\' THEN (sold_products.sold_count * sold_products.sale_unit_price) ELSE 0 END) AS total_sale')
          .select('SUM(CASE WHEN sold_products.entry_type = \'purchase\' THEN (sold_products.sold_count * sold_products.purchase_unit_price) ELSE 0 END) AS total_purchase')
          .select('SUM(CASE WHEN sold_products.entry_type = \'purchase return\' THEN (sold_products.sold_count * sold_products.purchase_unit_price) ELSE 0 END) AS purchase_return')
          .select('SUM(CASE WHEN sold_products.entry_type = \'purchase return\' THEN (sold_products.sold_count) ELSE 0 END) AS purchase_return_count')
          .select('SUM(CASE WHEN sold_products.entry_type = \'sale return\' THEN (sold_products.sold_count * sold_products.sale_unit_price) ELSE 0 END) AS sale_return')
          .select('SUM(CASE WHEN sold_products.entry_type = \'sale return\' THEN (sold_products.sold_count) ELSE 0 END) AS sale_return_count')
          .select('COUNT(*)  AS count_all')
          .where(company_id: current_user.company_id,is_active: true)
          .group('sold_products.product_id, p.name')
          query = query.where(sold_products: { product_id: params[:product_id] }) if params[:product_id].to_i > 0
          @data = query
        if( @data.present?)
          @pagy, entries = pagy(@data, items: items_per_page, page:page)
          # return render json: pagy
          render json:{ status: "Bind Successfully", data: entries, pagination: @pagy }, status: 200 and return
        else
          render json: { error: "Data not found"}, status: 204 and return
        end
    rescue Pagy::OverflowError
      @pagy, entries = pagy(@data, items: items_per_page, page:1)
      params[:page] = @pagy.last
      retry
    end
  end
  def stock_summery
    begin
      @stock_data = []
      purchase = 0
      purchase_return = 0
      sale = 0
      sale_return = 0

      items_per_page = 100
      params[:page].present? ? page = params[:page].to_i : page = 1
      # return render json: SoldProduct.joins(:product_entry).select('product_entries.item_profit')
      @data = SoldProduct.joins(:product_entry)
      .joins('JOIN products p ON sold_products.product_id = p.id')
      .select('sold_products.*,p.name, p.unit, p.id', 'product_entries.item_profit', 'product_entries.discount' )
      .where(company_id: current_user.company_id, is_active: true)
      .order(transaction_date: :desc)
      # return render json: @data
      purchase_discount = @data.where(order_type: "debit").sum(:discount)
      sale_discount = @data.where(order_type: "credit").sum(:discount)

      @data.each do |t|

        if t.entry_type.downcase == "purchase"
         sold_count =  t.sold_count
         price = t.net_unit_price.to_f
         purchase += (sold_count * price)
        elsif t.entry_type.downcase == "sale"
          sold_count =  t.sold_count
          price = t.sale_unit_price.to_f
          sale += (sold_count * price)
        elsif t.entry_type.downcase == "sale return"
          sold_count =  t.sold_count
          price = t.sale_unit_price.to_f
          sale_return += (sold_count * price)
        elsif t.entry_type.downcase == "purchase return"
          sold_count =  t.sold_count
          price = t.purchase_unit_price.to_f
          purchase_return += (sold_count * price)
        end
      end
      @stock_data << {type: "purchase",amount: purchase ,css_class: "bg-primary"}
      @stock_data << {type: "purchase return",amount: purchase_return,css_class: "bg-danger" }
      @stock_data << {type: "sale",amount: sale,css_class: "bg-success" }
      @stock_data << {type: "sale return",amount: sale_return,css_class: "bg-info" }
      @stock_data << {type: "purchase Discount",amount: purchase_discount ,css_class: "bg-primary"}
      @stock_data << {type: "Sale Discount",amount: sale_discount,css_class: "bg-danger" }

      if( @data.present?)
        @pagy, entries = pagy(@data, items: items_per_page, page:page)
        # return render json: pagy
        render json:{ status: "Bind Successfully", data: entries, pagination: @pagy , stock_data: @stock_data}, status: 200 and return
      else
        # render json: { error: "Data not found"}, status: 204 and return
        head :no_content
      end
    rescue Pagy::OverflowError
      @pagy, entries = pagy(@data, items: items_per_page, page:1)
      params[:page] = @pagy.last
      retry
    end
  end

  # Api::V1::DashboardController.company_trial_balance
  def company_trial_balance
    # return render json: params[:end_date] == 'undefined'
    incorporation_date = Company.find_by_id(current_user.company_id).incorporation_date

    if params[:end_date] == 'undefined'
      # start_date = params[:start_date].to_datetime > end_date || params[:start_date].to_datetime == end_date ? end_date-1.day : params[:start_date].to_datetime
      end_date = params[:start_date].to_datetime
      start_date = end_date-1.month
    else
      start_date = params[:start_date].to_datetime
      end_date = params[:end_date].to_datetime
    end

    # start_date = "05/08/2021".to_datetime
    # end_date = "18/09/2024".to_datetime
    ledgers = []
    @d = []
    @c = []
    @open = []
    @close = []

    Plutus::Account.where(company_id: current_user.company_id ).each do |l|
        @d <<  @debit_total =  l.amounts.joins(:entry).where(type: 'Plutus::DebitAmount', plutus_entries: {  date: start_date..end_date }).sum(:amount)
        @c <<  @credit_total  =  l.amounts.joins(:entry).where(type: 'Plutus::CreditAmount', plutus_entries: {  date: start_date..end_date }).sum(:amount)
        d = l.name.split("_")
        name = d.take(d.count - 1).join(" ")
        @open << open_bal =   l.balance(:from_date =>incorporation_date , :to_date => (start_date - 1.day).end_of_day).to_f
        close_bal = 0
        case l.type
          when "Plutus::Asset"

            temp_close =  l.balance(:from_date =>start_date.beginning_of_day , :to_date => end_date).to_f
            # return render json:  [temp_close , @debit_total,@credit_total]

            close_bal += ( ((temp_close.to_f).abs + @debit_total.to_f) - @credit_total.to_f )
            # close_bal << 0.5

          when "Plutus::Equity"
            temp_close =  l.balance(:from_date =>start_date.beginning_of_day , :to_date => end_date).to_f
            temp_close =  (temp_close + @credit_total )
            close_bal << (temp_close - @debit_total )
          when "Plutus::Expense"
            temp_close =  l.balance(:from_date =>start_date.beginning_of_day , :to_date => end_date).to_f
            temp_close =  (temp_close + @debit_total )
            close_bal << (temp_close - @credit_total)
          when "Plutus::Liability"
            temp_close =  l.balance(:from_date =>start_date.beginning_of_day , :to_date => end_date).to_f
            temp_close =  (temp_close + @credit_total )
            close_bal << (temp_close - @debit_total )
          when "Plutus::Revenue"
            temp_close =  l.balance(:from_date =>start_date.beginning_of_day , :to_date => end_date).to_f
            temp_close =  (temp_close + @debit_total )
            close_bal << (temp_close - @credit_total)

        end


        @close << close_bal
        #  == 0 ? open_bal : temp_close
        # @close << close_bal =  l.balance(:from_date =>incorporation_date , :to_date => end_date).to_f
        unless open_bal == 0 && close_bal == 0 && @credit_total == 0 && @debit_total == 0
          ledgers << {
            l_type: l.type.delete_prefix('Plutus::'),
            l_name: name,
            open_bal: open_bal,
            debit:@debit_total,
            credit: @credit_total,
            close_bal: close_bal ,
            test: @d.sum,
            slug: l.slug
          }
        end
    end

    if( ledgers.present?)

      render json:{
          status: "Bind Successfully",
          start:start_date,
          end: end_date,
          data: ledgers,
          dr_sum: @d.sum,
          cr_sum: @c.sum,
          open_bal: @open.sum,
          close_bal: @close.sum
        }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end

  # Api::V1::DashboardController.company_trial_balance_new
  def company_trial_balance_new
    # return render json: params[:end_date] == 'undefined'

    # start_date = "05/08/2021".to_datetime
    incorporation_date = Company.find_by_id(current_user.company_id)&.incorporation_date
    end_date = Date.strptime("31/01/2025", "%d/%m/%Y") # Ensure proper date conversion

    data = Plutus::Account.where(company_id: 1).map do |a|
      l_type = ["Plutus::Liability", "Plutus::Equity", "Plutus::Revenue"].include?(a.type) ? "credit" : "debit"

      a.as_json.merge({
        bal_cr:  l_type == 'credit'? a.balance(from_date: incorporation_date, to_date: end_date) : 0,
        bal_dr:  l_type == 'debit'? a.balance(from_date: incorporation_date, to_date: end_date) : 0,
        l_type: l_type,
        title:  a.type.sub("Plutus::", ""),
        m_name:  a.name.split("_")[0..-2].join(" ").upcase
      })
    end.reject { |account| account[:bal_cr] == 0 && account[:bal_dr] == 0 }
    cr_sum = data.sum { |d| d[:bal_cr] }
    dr_sum = data.sum { |d| d[:bal_dr] }
    items = data.group_by { |item| item[:title] }
    result = items.map do |key, values|
      {
        key: key,
        count: values.count,
        l_data: values.map { |v| v.except(:title) }
      }
    end
    if data.present?
      render json: { status: "success", data: result, cr_sum: cr_sum, dr_sum: dr_sum}, status: 200 and return
    else
      render json: { status: "No data"}, status: 401 and return
    end
  end


  # Api::V1::DashboardController.daybook
  # def self.daybook
  def daybook

    ledgers = []
    end_date = params[:start_date].to_datetime
    incorporation_date = Company.find_by_id(current_user.company_id).incorporation_date
    # incorporation_date = Company.find_by_id(1).incorporation_date

    Plutus::Account.where(company_id: current_user.company_id ).each do |l|
    # Plutus::Account.where(company_id: 1 ).each do |l|
          d = l.name.split("_")
          name = d.take(d.count - 1).join(" ")
           open_bal =  l.balance(:from_date =>incorporation_date , :to_date => (end_date-1.day).end_of_day).to_f
           today =  l.balance(:from_date =>end_date.beginning_of_day , :to_date => end_date.end_of_day).to_f
           close_bal =  l.balance(:from_date =>incorporation_date , :to_date => end_date.end_of_day).to_f
          unless open_bal == 0 && close_bal == 0
            ledgers << {
              l_type: l.type.delete_prefix('Plutus::'),
              l_name: name,
              open_bal: open_bal,
              close_bal: close_bal,
              day_bal: today,
              slug: l.slug
            }
          end

    end
    if( ledgers.present?)
      render json:{
          status: "Bind Successfully",
          start:end_date,
          data: ledgers,
         }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end

  # Api::V1::DashboardController.income_statement
  # def self.income_statement
  def income_statement
    if params[:end_date] == 'undefined' || params[:start_date] == 'undefined'
      start_date = (Date.today-1.month).at_beginning_of_month
      end_date = Date.today
    else
      start_date = params[:start_date].to_date
      end_date = params[:end_date].to_date
    end
    ledger_rev = []
    ledger_rev_amt = []
    ledger_exp = []
    ledger_exp_amt = []
    Plutus::Account.where(company_id: current_user.company_id, type: ["Plutus::Revenue", "Plutus::Expense"] ).each do |l|
    # Plutus::Account.where(company_id: 1, type: ["Plutus::Revenue", "Plutus::Expense"] ).each do |l|
        d = l.name.split("_")
        name = d.take(d.count - 1).join(" ")
        bal = l.balance(:from_date =>start_date , :to_date => end_date).to_f
       if l.type == "Plutus::Revenue" && bal != 0
        ledger_rev_amt << bal
        ledger_rev << {l_name: name,bal: bal, slug: l.slug }
       elsif l.type == "Plutus::Expense" && bal != 0
        ledger_exp_amt << bal
        ledger_exp << {l_name: name,bal: bal, slug: l.slug }
       end

    end
    if( ledger_rev.present? || ledger_exp.present?)

      render json:{
          status: "Bind Successfully",
          start:start_date,
          end: end_date,
          ledger_rev: ledger_rev,
          ledger_rev_amt: ledger_rev_amt.sum,
          ledger_exp: ledger_exp,
          ledger_exp_amt: ledger_exp_amt.sum,
        }, status: 200 and return
    else
      render json: { error: "Data not found",
       start:start_date,
        end: end_date
        }, status: 401 and return
    end


  end
  # Api::V1::DashboardController.get_all_products
  def get_all_products_dashboard
   products =  SoldProduct.joins("LEFT JOIN products p ON p.id = sold_products.product_id")
   .select("p.name, p.id, p.part_no").where.not(p: {name: nil})
   render json:{
          status: "Bind Successfully",
          data: products
        }, status: 200 and return
  end


end

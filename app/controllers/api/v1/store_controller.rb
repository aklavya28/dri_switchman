class Api::V1::StoreController < ApplicationController
  before_action :authenticate_user!
  require 'json'
  require 'pagy/extras/jsonapi'

  def create_category
    # return render json: params , status: 401
     @duplicate =  ProductCategory.where("name =? AND company_id =?", params[:name], params[:company_id]).first
     if @duplicate.present?
      render json: { error: "Category already exist"}, status: 401 and return
     end

    @category = ProductCategory.new(model_params)
    @category.user_id = params[:user_id]
    @category.company_id = params[:company_id]
    if(@category.save!)
      render json:{ message: "Category Registered Successfully", data: @category }, status: 200 and return
    else
        render json: { error: "Data not Saved", err_message: @category.errors.full_messages }, status: 401 and return
    end
  end



  def get_product_categories
    if(params[:company_id])
      @categories =  ProductCategory.where(company_id: params[:company_id]).order(name: :asc)
      render json:{ message: "Success", data: @categories }, status: 200 and return
    else
      render json: { error: "Something wrong "}, status: 401 and return
    end

  end

  def purchase_product_categories
      company_id = current_user.company_id
      @categories = Product.where(company_id: company_id)
      .select('DISTINCT products.product_category_id, product_categories.*')
      .joins(:product_category).order('product_categories.name ASC')
    if @categories
      render json:{ message: "Success", data: @categories }, status: 200 and return
    else
      render json: { error: "Something wrong "}, status: 401 and return
    end

  end
  def create_product

    @duplicate =  Product.where("product_category_id =? AND name =? AND company_id =?", params[:product_category_id], params[:name], current_user.company_id).first
    if @duplicate.present?
      render json: { error: "Proudct already exist"}, status: 401 and return
    end
      @product = Product.new(model_params)
      # @product.product_category_id = ProductCategory.find_by_id(params[:product_category_id]).id
      @product.company_id = current_user.company_id
      @product.user_id = current_user.id
      if @product.save!

      render json:{ status: "Product Registered Successfully", data: @product }, status: 200 and return
      else
        render json: { error: "Data not Saved", err_message: @product.errors.full_messages }, status: 401 and return
      end
  end
  def get_products
    @products = Product.where(company_id: params[:company_id], product_category_id: params[:category_id])
    if(@products)
      render json:{ status: "Success", data: @products }, status: 200 and return
    else
        render json: { error: "No Product listed under this category" }, status: 401 and return
    end
  end
  def get_venders
    @venders =  Plutus::Account.where(company_id: params[:company_id], is_system: false)
    if(@venders)
        render json:{ status: "Success", data: @venders }, status: 200 and return
    else
        render json: { error: "No vender found" }, status: 401 and return
    end
  end

  def create_order
        begin
            ActiveRecord::Base.transaction do
              apidat = params[:data]
              order_date = (apidat[:order_date].to_datetime + 6.hours).to_date
              order_ledger_balance_checking =  order_balance_checking(current_user.company_id, apidat)
              if order_ledger_balance_checking.present?
                render json: { error1: "Data not Saved", err_message: order_ledger_balance_checking }, status: 401 and return
              end

              @order = Order.new(model_params_order)
                if(params[:data][:order_type] == 'Debit')
                  @order.gst_paid = apidat[:bill_calculations][:grand_gst].to_f.round(2)
                end

                @order.order_date = order_date
                @order.discount = apidat[:bill_calculations][:grand_discount].to_f.round(2)
                @order.grand_total = apidat[:bill_calculations][:grand_total].to_f.round(2)
                @order.round_off_amount = apidat[:bill_calculations][:round_off_amount].to_f.round(2)
                @order.company_id = current_user.company_id
                @order.user_id = current_user.id
                @order.status = "order_not_approve"
                # updating gst type status
                khata_state = Khatabook.find_by_id(apidat[:khatabooks_id]).state_id
                company_state = current_user.company.state_gst_id
                if khata_state != company_state
                  @order.is_igst = true
                end

                if @order.save!
                      # assets
                      if apidat[:assets].length > 0
                        apidat[:assets].each_with_index do |product, index|
                          @assets = @order.fixed_assets.new(apidat.fetch(:assets, {})[index].except(:taxable,:id,:order_date,:refrence_id).permit!)
                            @assets.assets_type = "debit"
                           if @assets.save!
                            @record = @assets.record_fixed_assets.new
                            @record.assets_type = @assets.assets_type
                            @record.no_of_unit = @assets.no_of_unit
                            @record.unit_amount = @assets.unit_amount
                            @record.save!
                           end
                          end
                      end
                      # assets
                              # services
                      if apidat[:services_items].length > 0
                        apidat[:services_items].each_with_index do |product, index|
                          @service = @order.sale_service_transactions.new(apidat.fetch(:services_items, {})[index].except(:choose_service,:t_date,:gst_percent,:gst).permit!)
                            @service.company_id = current_user.company_id
                            @service.user_id = current_user.id
                            @service.t_date = order_date
                            @service.khatabook_id = @order.khatabooks_id
                            @service.service_type = "credit"
                            @service.save!
                          end
                      end
                      # services


                  apidat[:items].each_with_index do |product, index|
                    net_unit_price = ((product[:unit_price].to_f.round(2)) - ((product[:unit_price].to_f.round(2)) * (@order.discount_percent.to_f.round(2)) / 100)).to_f.round(2)
                    # JSON.parse(apidat[:items][0]
                    # product_id = product[:product_description].split(",").first.to_i;
                    # product_id = JSON.parse(product[:product_description], symbolize_names: true)[:id]
                    product_id = product[:product_description][:id]

                    @item =  @order.product_entries.new(params[:data].fetch(:items, {})[index].except(:gst_percent,:product_name,:taxable).permit!)
                    @item.product_id = product_id
                    @item.category_id = product[:product_description][:product_category_id]
                    @item.company_id = current_user.company_id
                    # @item.product_description = JSON.parse(product[:product_description])
                    @item.product_description = product[:product_description]
                    @item.user_id = current_user.id
                    @item.product_type = "debit"
                    @item.net_unit_price = net_unit_price

                    if @item.save!
                          # create sold products entry
                        @sold = @item.sold_products.new()
                        @sold.entry_type = "purchase"
                        @sold.order_type = "debit"
                        @sold.product_id = product_id
                        @sold.order_id = @item.order_id
                        @sold.sold_count = @item.no_of_unit
                        @sold.mrp = @item.mrp
                        @sold.company_id = current_user.company_id
                        @sold.purchase_unit_price = @item.unit_price
                        @sold.category_id = product[:product_description][:product_category_id]
                          # pass time to date
                        date = @order.order_date.to_date
                        current_time = Time.current
                        order_date = DateTime.new(date.year, date.month, date.day, current_time.hour, current_time.min, current_time.sec)
                        @sold.transaction_date = order_date
                        # pass time to date
                        @sold.is_active = @order.auto_approved == true ? true : false
                        @sold.net_unit_price = net_unit_price
                        @sold.save!

                    else
                      raise ActiveRecord::Rollback
                    end
                  end
                  ::Order.update_order_total(@order.id)
                  if @order.auto_approved
                    auto_approved_order(@order.id)

                  end


                else
                  raise ActiveRecord::Rollback
                end
            end
          render json:{ status: "Order Placed Successfully", data: @order }, status: 200 and return
        rescue => e
          # Handle any exceptions

          message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
          render json: { error: message, app_error: e.message }, status: :unprocessable_entity
          # ensure
          #   # Cleanup code that runs whether or not the transaction is successful
          #   cleanup_task

        end
  end
  # edit_purchase_order_method
  def update_purchase_order
    # return render json: {data: params,message: "failed"}, status:401
    begin
      ActiveRecord::Base.transaction do
        apidat = params[:data]
        order_date = (apidat[:order_date].to_datetime + 6.hours).to_date
        order_ledger_balance_checking =  order_balance_checking(current_user.company_id, apidat)
        # return render json: apidat
        if order_ledger_balance_checking.present?
          render json: { error1: "Data not Saved", err_message: order_ledger_balance_checking }, status: 401 and return
        end

          @order = Order.find_by_slug(apidat[:slug])

          if(params[:data][:order_type] == 'Debit')
            @order.gst_paid = apidat[:bill_calculations][:grand_cgst].to_f.round(2) + apidat[:bill_calculations][:grand_sgst].to_f.round(2) + apidat[:bill_calculations][:grand_igst].to_f.round(2)
          end
          state_gst_id = Company.find_by_id(@order.company_id).state_gst_id
          khata_state_id = @order.khatabook.state_id
          if @order.update!(
                  order_date: order_date,
                  gst_paid: apidat[:bill_calculations][:grand_gst].to_f.round(2),
                  discount: apidat[:bill_calculations][:grand_discount].to_f.round(2),
                  grand_total: apidat[:bill_calculations][:grand_total].to_f.round(2),
                  round_off_amount: apidat[:bill_calculations][:round_off_amount].to_f.round(2),
                  company_id: current_user.company_id,
                  user_id: current_user.id,
                  discount_percent: apidat[:discount_percent],
                  paid_from: apidat[:paid_from],
                  mobile_no: apidat[:mobile_no],
                  ack_no: apidat[:ack_no],
                  auto_approved: apidat[:auto_approved],
                  irn_no: apidat[:irn_no],
                  khatabooks_id: apidat[:khatabooks_id],
                  vechile_no: apidat[:vechile_no],
                  is_igst: state_gst_id == khata_state_id ? true : false
                )

                # assets
                @o_assets = @order.fixed_assets
                @live_assets =  apidat[:assets]
                @saved_assets_ids =  @o_assets.map{|i|i[:id] }.compact
                @live_assets_ids_old =  @live_assets.map{|i|i[:id] }.compact
                @live_assets_ids_new =  []
                @live_assets.map do |i|
                  if i[:id].nil?
                    @live_assets_ids_new << i
                  end
                end
                unavilable_asset_ids = (@saved_assets_ids - @live_assets_ids_old) + (@live_assets_ids_old - @saved_assets_ids)
                unavilable_asset_ids.each do |a|
                  fixed = FixedAsset.find_by_id(a)
                  fixed.record_fixed_assets.each {|rf| rf&.destroy!}
                  fixed&.destroy!
                end
                @live_assets.each_with_index do |ass, index|
                  unless  ass[:id].present?
                    @assets = @order.fixed_assets.new(apidat.fetch(:assets, {})[index].except(:taxable,:id,:order_date,:refrence_id).permit!)
                    @assets.assets_type = "debit"
                    if @assets.save!
                     @record = @assets.record_fixed_assets.new
                     @record.assets_type = @assets.assets_type
                     @record.no_of_unit = @assets.no_of_unit
                     @record.unit_amount = @assets.unit_amount
                     @record.save!
                    end
                  end
                end
                # services
                @o_services = @order.sale_service_transactions
                @live_service =  apidat[:services_items]
                @saved_service_ids =  @o_services.map{|i|i[:id] }.compact
                @live_service_ids_old =  @live_service.map{|i|i[:id] }.compact
                @live_service_ids_new =  []
                @live_service.map do |i|
                  if i[:id].nil?
                    @live_service_ids_new << i
                  end
                end
                unavilable_ids = (@saved_service_ids - @live_service_ids_old) + (@live_service_ids_old - @saved_service_ids)
                # destroy unwanted services
                unavilable_ids.each{|s| SaleServiceTransaction.find_by_id(s).destroy!}
                # update and create new services
                @live_service.each_with_index do |ser, index|
                  if ser[:id].present?
                    SaleServiceTransaction.find_by_id(ser[:id]).update!(
                      khatabook_id: @order.khatabooks_id
                    )
                  else
                      @service = @order.sale_service_transactions.new(apidat.fetch(:services_items, {})[index].except(:choose_service,:t_date,:gst_percent ).permit!)
                      @service.company_id = current_user.company_id
                      @service.user_id = current_user.id
                      @service.t_date = order_date
                      @service.khatabook_id = @order.khatabooks_id
                      @service.service_type = "credit"
                     if @service.save!
                     else
                      raise ActiveRecord::Rollback
                     end

                  end
                end
                # services
                # product
                @o_product = @order.product_entries
                @live_product =  apidat[:items]
                @o_product_ids =  @o_product.map{|i|i[:id] }.compact
                @live_product_ids_old =  @live_product.map{|i|i[:id] }.compact
                @live_product_ids_new =  []
                @live_product.map do |i|
                  if i[:id].nil?
                    @live_product_ids_new << i
                  end
                end
                unavilable_ids = (@o_product_ids - @live_product_ids_old) + (@live_product_ids_old - @o_product_ids)
                # destroy unwanted products
                unavilable_ids.each do |i|
                  SoldProduct.find_by_product_entries_id(i)&.destroy!
                  ProductEntry.find_by_id(i)&.destroy!
                end
                  # update and create new products
                  @live_product.each_with_index do |product, index|
                    unless product[:id].present?
                        @item =  @order.product_entries.new(params[:data].fetch(:items, {})[index].except(:taxable, :gst_percent, :product_name).permit!)
                        @item.product_id = product[:product_description][:id]
                        @item.company_id = current_user.company_id
                        @item.product_description = product[:product_description]
                        @item.user_id = current_user.id
                        @item.category_id = product[:product_description][:product_category_id]
                        @item.product_type = "debit"
                       if @item.save!
                          @sold = @item.sold_products.new()
                          @sold.entry_type = "purchase"
                          @sold.order_type = "debit"
                          @sold.product_id = product[:product_description][:id]
                          @sold.order_id = @item.order_id
                          @sold.sold_count = @item.no_of_unit
                          @sold.category_id = product[:product_description][:product_category_id]
                          @sold.mrp = @item.mrp
                          @sold.company_id = current_user.company_id
                          @sold.purchase_unit_price = @item.unit_price
                            # pass time to date
                          date = @order.order_date.to_date
                          current_time = Time.current
                          order_date = DateTime.new(date.year, date.month, date.day, current_time.hour, current_time.min, current_time.sec)
                          @sold.transaction_date = order_date
                          # pass time to date
                          @sold.is_active = @order.auto_approved == true ? true : false
                          @sold.save!
                       else
                          raise ActiveRecord::Rollback
                       end

                    end
                  end

                # product end
                ::Order.update_order_total(@order.id)
            # Api::V1::StoreController.update_order_total(@order.id)
            if @order.auto_approved
              auto_approved_order(@order.id)
            end
          else
            raise ActiveRecord::Rollback
          end
      end
    render json:{ status: "Order Placed Successfully", data: @order }, status: 200 and return
    rescue => e
      # Handle any exceptions
      message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
      # ensure
      #   # Cleanup code that runs whether or not the transaction is successful
      #   cleanup_task
    end
  end

  def get_all_products

    @comp_id = current_user.company_id
    if(params[:store].present?)
      @product = Product.where(company_id: current_user.company_id).joins(:product_category).where("products.product_category_id =? AND products.#{params[:store][:type]} LIKE ?",params[:store][:categories_list],"%#{params[:store][:search_key]}%").select('products.*,product_categories.name as category')
      else
     @product = Product.where(company_id: current_user.company_id).joins(:product_category).select('products.*,product_categories.name as category')
    end


    # return render json:  @product = Product.includes(:product_category).where(company_id: @comp_id).take(10)
    if @product.present?
        render json:{ status: "Product load Successfully", data: @product }, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 401 and return
    end
  end
  # orders page
  def all_orders

    # return render  json:  @new_form_pams["seach_value"]
    begin
      @new_form_pams = JSON.parse(params[:data]) if params[:data]  != 'undefined'
      items_per_page = 50
      params[:page].present? ? page = params[:page].to_i : page=  1

      # search form
      if  params[:data]  != 'undefined' && @new_form_pams["seach_value"].present?
      # return render json:[ params[:data][:search_by] ,  params[:data][:seach_value]]

       @orders_data = Order.where(company_id: current_user.company_id,occupied: false, order_type: ['credit', 'debit'])
       .where("#{@new_form_pams["search_by"]} LIKE ?", "%#{@new_form_pams["seach_value"]}%")
       .joins(:khatabook).select('orders.*, khatabooks.name, khatabooks.company_name, khatabooks.address, khatabooks.mobile')
       .order( order_date: :desc)
      elsif params[:data]  != 'undefined' && @new_form_pams["end"].present? && !@new_form_pams["order_type"].present?
      # return render json: [params[:data][:start].to_date, params[:data][:end].to_date]
      @orders_data = Order.where(company_id: current_user.company_id,occupied: false, order_type: ['credit', 'debit'])
       .where( order_date: (@new_form_pams["start"].to_date)+1.day..(@new_form_pams["end"].to_date)+1.day)
       .joins(:khatabook).select('orders.*, khatabooks.name, khatabooks.company_name, khatabooks.address, khatabooks.mobile')
       .order( order_date: :desc)
      elsif params[:data]  != 'undefined' && @new_form_pams["order_type"].present?
          case  @new_form_pams["order_type"]
          when "purchase"
              query = "order_type = 'debit' AND is_returned = false "
          when "purchase_return"
              query = "order_type = 'credit' AND is_returned = true "
          when "sale"
              query = "order_type = 'credit' AND  is_returned = false "
          when "sale_return"
              query = "order_type = 'debit' AND is_returned = true"
          when "not_approved"
              query = "order_type IN ('debit', 'credit') AND auto_approved = false"
          end
        @orders_data = Order.where(company_id: current_user.company_id,occupied: false)
        .where(query)
        .where( order_date: (@new_form_pams["start"].to_date)+1.day..(@new_form_pams["end"].to_date)+1.day)
        .joins(:khatabook).select('orders.*, khatabooks.name, khatabooks.company_name, khatabooks.address, khatabooks.mobile')
        .order( order_date: :desc)
      else
        @orders_data = Order.where(company_id: current_user.company_id,occupied: false, order_type: ['credit', 'debit']).joins(:khatabook).select('orders.*, khatabooks.name, khatabooks.company_name, khatabooks.address, khatabooks.mobile').order( order_date: :desc)
      end
        @pagy, entries = pagy(@orders_data, items: items_per_page, page:page)
      if @orders_data.present?
        render json:{ status: "Bind Successfully", data: entries, pagination: @pagy }, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 204 and return
      end
    rescue Pagy::OverflowError
      @pagy, entries = pagy(@orders_data, items: items_per_page, page:1)
      params[:page] = @pagy.last
    retry
    end
  end
  # orders page
  def get_order
    @order  = Order.find_by_slug(params[:slug])
    product_taxable = []
    if @order.present?

      vendor = Khatabook.find(@order.khatabooks_id)
      if @order.order_type.downcase == 'debit' && @order.is_returned
        products = @order.product_entries.where(product_type: 'sale return').map do |t|
          product_taxable << ( t.total - t.gst ).to_f.round(2)
          t.as_json.merge({
            taxable: ( t.total - t.gst ).to_f.round(2)
          })
        end
      else
        products = @order.product_entries.map do |t|
          product_taxable << ( t.total - t.gst ).to_f.round(2)
          t.as_json.merge({
            taxable:( t.total - t.gst ).to_f.round(2)
          })
        end
      end
      services = @order.sale_service_transactions.joins(:sale_service).select('sale_service_transactions.*','sale_services.gst,sale_services.name ')
      # return render  json:@order.fixed_assets
      assets = @order.fixed_assets.map do |t|
                    cr =   t.record_fixed_assets.where(assets_type: "credit").sum{ |a| a.no_of_unit }
                    dr =   t.record_fixed_assets.where(assets_type: "debit").sum{ |a| a.no_of_unit }
                    t.as_json.merge({
                      available: (dr - cr)
                  })
                end
      # return render  json: assets
      t_order =  @order.as_json.merge({
                  "assets_total":  @order.fixed_assets.sum{|a| (a.unit_amount.to_f.round(2)) * a.no_of_unit}.to_f,
                  "assets": assets
                })

      ser_total = services.sum(:amount).to_f

      company= Company.find_by_id(current_user.company_id)
      @data = { :vendor => vendor, :products => products, :company => company, :order => t_order, :services=> services, product_taxable: product_taxable.sum.to_f.round(2), :ser_total=>ser_total}
      render json:{ status: "Product load Successfully", data: @data }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end

  end
  # sale
  # Api::V1::StoreController.get_product_sale_categories
  def get_product_sale_categories
  # def self.get_product_sale_categories
    availableCats = []
    categories =   SoldProduct.select(:category_id).distinct.pluck(:category_id)
    categories.each do |c|
      dr =  SoldProduct.where(order_type: 'debit', is_active: true, category_id: c).sum(:sold_count)
      cr =  SoldProduct.where(order_type: 'credit',  category_id: c).sum(:sold_count)
      if dr > cr
        availableCats << ProductCategory.find_by_id(c)
      end
    end
    # return availableCats
    render json:{ status: "success", data: availableCats }, status: 200 and return
  end
  # Api::V1::StoreController.get_product_sale_products
  def get_product_sale_products
    availableProducts = []
    all_products  = SoldProduct.where(category_id: params[:category_id]).select(:product_id).distinct.pluck(:product_id)
    all_products.each do |p|
      dr =  SoldProduct.where(order_type: 'debit', is_active: true, product_id: p).sum(:sold_count)
      cr =  SoldProduct.where(order_type: 'credit',  product_id: p).sum(:sold_count)
      if dr > cr
        availableProducts << Product.find_by_id(p)
      end
    end
    render json:{ status: "success", data: availableProducts }, status: 200 and return
  end


  # def get_product_sale_products2

  #   @products = ProductEntry
  #  .joins(:order, :product)
  #  .where(orders: { company_id: current_user.company_id,auto_approved: true})
  #  .where(category_id: params[:category_id])
  #  .select(
  #    'product_entries.product_id,
  #    products.*,
  #     SUM(CASE
  #         WHEN product_entries.product_type = \'debit\' AND product_entries.availablity = \'available\'
  #         THEN product_entries.no_of_unit
  #         ELSE 0
  #     END) AS debit_unit,
  #     SUM(CASE
  #         WHEN product_entries.product_type = \'credit\' AND product_entries.availablity = \'available\'
  #         THEN product_entries.no_of_unit
  #         ELSE 0
  #     END) AS credit_unit,
  #     SUM(CASE
  #       WHEN product_entries.product_type = \'credit\' AND product_entries.availablity = \'notavailable\'
  #       THEN product_entries.no_of_unit
  #       ELSE 0
  #   END) AS temp_credit,
  #     (SUM(CASE
  #         WHEN product_entries.product_type = \'debit\' AND product_entries.availablity = \'available\'
  #         THEN product_entries.no_of_unit
  #         ELSE 0
  #     END) -
  #     SUM(CASE
  #         WHEN product_entries.product_type = \'credit\' AND product_entries.availablity = \'available\' OR product_entries.availablity = \'notavailable\'
  #         THEN product_entries.no_of_unit
  #         ELSE 0
  #     END)) AS available_units'
  #  )
  #  .group('product_entries.product_id')
  #  .having('available_units > 0')
  #       if @products.present?
  #         render json:{ status: "success", data: @products }, status: 200 and return
  #       else
  #         render json: { error: "Data not found"}, status: 401 and return
  #       end
  # end
  def sale_purchase_count(company, category, type)
    data = ProductEntry
      .joins(:order) # Inner join with orders
      .where(orders: { company_id: company, status: 'processed' })
      .where(category_id: category, availablity: 'available', product_type: type)
      .select('DISTINCT product_entries.product_id, SUM(product_entries.no_of_unit) AS unit') # Select distinct product_id and sum of no_of_unit
      .group('product_entries.product_id')
      return data
  end
  # Api::V1::StoreController.marp_with_product(catid =3, pid=13, company_id=1)
  def self.marp_with_product
      @cat_temp = []
      @pro_id = []
      ProductEntry.where(company_id: 1).select("distinct(product_id)").each do |p|
        @pro_id << p.product_id
      end
      # return puts @pro_id
      if (@pro_id.present?)
        @pro_id.each do |product|
          # return puts product
          dr_product = ProductEntry.where(product_id: product, product_type: 'debit',  availablity: 'available' ).sum(:no_of_unit)
          cr_product = ProductEntry.where(product_id: product, product_type: 'credit',  availablity: 'available').sum(:no_of_unit)
          # return puts [dr_product.to_f.round(0), cr_product.to_f.round(0)]
          if(dr_product > cr_product)
             @cat_temp << ProductEntry.where(product_id: product).first.category_id
          end

        end
      end
      if(@cat_temp.present?)
        return puts    ProductCategory.where(id: @cat_temp)
      end

  end


  def get_product_sale_products_mrps
    @mrp = []
    ProductEntry.where(company_id: current_user.company_id, availablity: 'available', product_type: 'debit', product_id: params[:product_id]).group(:mrp, :product_id)
    .select("count(mrp) as mrp_count,sum(no_of_unit) as total_unit, mrp, product_id").each do |row|
      mpr_cr =  ProductEntry.where(mrp:row.mrp.to_f.round(2) , company_id: current_user.company_id, product_type: 'credit', product_id: params[:product_id]).sum(:no_of_unit)
      unless((row.total_unit - mpr_cr ) < 1 || (row.total_unit - mpr_cr ) == 0)
        @mrp << {:cr_unit => mpr_cr, :mrp => row.mrp.to_f.round(2), :total_unit => row.total_unit - mpr_cr, :product_id => row.product_id}
      end

    end
    # return render json: @mrp
    if @mrp.present?
      render json:{ status: "success", data: @mrp }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end

  end

  def get_sale_product_unit_price_old
    @mrp = []
    ProductEntry.where(is_sold:false, company_id: current_user.company_id, availablity: 'available', product_type: ['debit', 'debit sale return'], product_id: params[:product_id], is_returned: false).group(:unit_price, :product_id)
    .select("count(unit_price) as unit_price_count,sum(no_of_unit) as total_unit, unit_price, product_id, mrp").each do |row|

      mpr_cr =  ProductEntry.where(is_sold:false, old_unit_price:row.unit_price.to_f.round(2) , company_id: current_user.company_id, product_type: 'credit', product_id: params[:product_id]).sum(:no_of_unit)
      purchase_returns =  SoldProduct.where(purchase_unit_price: row.unit_price.to_f.round(2), product_id: params[:product_id], entry_type: "purchase return").sum(:sold_count)

      unless((row.total_unit - mpr_cr ) < 1 || (row.total_unit - (mpr_cr + purchase_returns) ) == 0)
        @mrp << {:cr_unit => mpr_cr, :unit_price => row.unit_price.to_f.round(2), :total_unit => row.total_unit - (mpr_cr + purchase_returns),  :product_id => row.product_id, mrp: row.mrp}
      end

    end
    # return render json: @mrp
    if @mrp.present?
      render json:{ status: "success", data: @mrp }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end

  end
  # Api::V1::StoreController.get_sale_product_unit_price
  def get_sale_product_unit_price
    id = params[:product_id]
    # id = 55
      @mrp = []
     SoldProduct.where(product_id: id,order_type: "debit").distinct(:net_unit_price).select(:net_unit_price, :purchase_unit_price).each do |p|
    # SoldProduct.where(product_id: id).distinct(:net_unit_price,).select("net_unit_price").each do |p|
      dr =  SoldProduct.where(product_id: id, order_type: "debit", net_unit_price: p.net_unit_price, is_active: true)
      cr =  SoldProduct.where(product_id: id, order_type: "credit", net_unit_price: p.net_unit_price)
      # temp_sold = ProductEntry.where(product_id: id,availablity: "notavailable",old_unit_price: p.net_unit_price).sum(:no_of_unit).to_f
      # updated_code total unit not present
        totalUnit = (dr.sum(:sold_count) - (cr.sum(:sold_count)))
      if totalUnit > 0
        # @mrp <<  {:cr_unit => cr.sum(:sold_count), :unit_price => p.purchase_unit_price.to_f, :total_unit => (dr.sum(:sold_count) - (cr.sum(:sold_count) + temp_sold)),  :product_id => id, mrp: dr.last.mrp.to_f }
        @mrp <<  {:cr_unit => cr.sum(:sold_count), :unit_price_with_discount => p.purchase_unit_price.to_f, :unit_price => p.net_unit_price.to_f, :total_unit => totalUnit,  :product_id => id, mrp: dr.last.mrp.to_f }
      end
    end
    # puts @mrp
      if @mrp.present?
        render json:{ status: "success", data: @mrp }, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 401 and return
      end
  end

  def get_sale_products_available_units
    SoldProduct.where(product_id: params[:product_id]).distinct(:net_unit_price).select("net_unit_price").each do |p|
      dr_unit =  SoldProduct.where(product_id: params[:product_id], order_type: "debit", net_unit_price: params[:unit_price])
      cr_unit =  SoldProduct.where(product_id: params[:product_id], order_type: "credit", net_unit_price: params[:unit_price]).sum(:sold_count)
      # temp_sold = ProductEntry.where(product_id: params[:product_id],availablity: "notavailable",old_unit_price: params[:unit_price]).sum(:no_of_unit).to_f
      totalUnit = (dr_unit.sum(:sold_count) - (cr_unit))
      if totalUnit > 0
        gst =  Product.find_by_id(params[:product_id]).gst
        data = {:available_units => totalUnit, :gst =>  gst, :unit_price => params[:unit_price]}
        render json:{ status: "success", data: data}, status: 200 and return
      else
        render json: { error: "Data not found"}, status: 401 and return
      end
    end
  end


  def remove_temp_user_order_items
    @order = Order.where(occupied: true, company_id: current_user.company_id ).first
    # [current_user.id, current_user.company_id]

    if(@order.present?)
      @order.product_entries.where(user_id: current_user.id, company_id: current_user.company_id).each do |e|
        e.sold_products.each {|s| s&.destroy!}
        e&.destroy!
      end
      @order.fixed_assets.each do |as|
        as.record_fixed_assets.each {|r| r&.destroy!}
         RecordFixedAsset.where(refrence_id: as.id).each {|p| p&.destroy!}
        as&.destroy!
      end
      if @order.present?
        render json:{ status: "success", data: @order}, status: 200 and return
      else
        render json:{ status: "Not temp products found"}, status: 200 and return
      end
    else
      # khata book
      @khatabook = Khatabook.where(name:  "System Khata", pan: "undefined", company_id: current_user.company_id, user_id: current_user.id).first
      unless @khatabook.present?
        @khatabook =   Khatabook.create!(name: "System Khata",khata_type: "debtor", pan: "undefined", company_id: current_user.company_id, user_id: current_user.id)
        @khatabook.update(ledger_name: "#{@khatabook.name.downcase.split(" ").join("_")}_#{@khatabook.id}")
      end
    # khata book
    @order = Order.where("khatabooks_id =? AND user_id =? AND occupied =? AND company_id =? ", @khatabook.id, current_user.id, true, current_user.company_id ).last

    unless @order.present?
      @order =   Order.create!(occupied: true, order_type: "Credit", khatabooks_id: @khatabook.id, company_id: current_user.company_id, user_id: current_user.id)
      render json:{ status: "success", data: @order}, status: 200 and return
    else
      render json:{ status: "Not temp products found"}, status: 200 and return
    end
      # render json: { error: "Data not found"}, status: 401 and return
    end

  end
  def remove_temp_single_product
      @order = Order.where(user_id: current_user.id, company_id: current_user.company_id, occupied: true).first
      # ProductEntry.where(order_id: @order.id,  )
      @product = ProductEntry.where(order_id: @order.id, total: params[:total].to_f.round(2)).where("JSON_EXTRACT(product_description, '$.name') = ?", params[:product_description][:name])
      if @product.present?
          @product.first.destroy()
        render json:{ status: "success"}, status: 200 and return
      else
         render json: { error: "Data not found"}, status: 401 and return
      end
  end

  def save_sale_order
    # return render json: { data: params[:data], status: "Order Placed Successfully"}, status: 401
    begin
      ActiveRecord::Base.transaction do
        # return render json: { data: params}, status:401
        apidat = params[:data]
        order_date = (apidat[:order_date].to_datetime + 6.hours).to_date

        # return render json: apidat[:discount_percent]
        @order = Order.find_by_slug(apidat[:slug])
        @order_update = @order.update!(
          ack_no: apidat[:ack_no],
          auto_approved: apidat[:auto_approved],
          irn_no: apidat[:irn_no],
          khatabooks_id: apidat[:khatabooks_id],
          discount_percent: apidat[:discount_percent],
          mobile_no: apidat[:mobile_no],
          vechile_no: apidat[:vechile_no],
          user_id: current_user.id,
          company_id: current_user.company_id,
          round_off_amount: apidat[:bill_calculations][:round_off_amount],
          discount: apidat[:bill_calculations][:grand_discount],
          grand_total: apidat[:bill_calculations][:grand_total],
          paid_from: apidat[:paid_from],
          order_type: apidat[:order_type],
          order_date: order_date,
          occupied: false,
          status: "order_not_approve"
        )
        unless @order_update
          raise ActiveRecord::Rollback
        end

        @order.product_entries.each do |e|
          e.update!(availablity: "available")
        end


       # return render json: @order_update
       @o_services = @order.sale_service_transactions
        @live_service =  params[:data][:services_items]
        @saved_service_ids =  @o_services.map{|i|i[:id] }.compact
        @live_service_ids_old =  @live_service.map{|i|i[:id] }.compact
        @live_service_ids_new =  []
        @live_service.map do |i|
          if i[:id].nil?
            @live_service_ids_new << i
          end
        end

        unavilable_ids = (@saved_service_ids - @live_service_ids_old) + (@live_service_ids_old - @saved_service_ids)
        # destroy unwanted services
        unavilable_ids.each{|s| SaleServiceTransaction.find_by_id(s).destroy!}
        # update and create new services
        @live_service.each_with_index do |ser, index|
          if ser[:id].present?
            SaleServiceTransaction.find_by_id(ser[:id]).update!(
              khatabook_id: params[:data][:khatabooks_id]
            )
          else
              @service = @order.sale_service_transactions.new(apidat.fetch(:services_items, {})[index].except(:choose_service,:t_date,:gst_percent ).permit!)
              @service.company_id = current_user.company_id
              @service.user_id = current_user.id
              @service.t_date = order_date
              @service.khatabook_id = params[:data][:khatabooks_id]
              @service.service_type = "debit"
             if @service.save!
             else
              raise ActiveRecord::Rollback
             end

          end
        end


        ::Order.update_order_total( @order.id, @order.paid_from)

        if @order.auto_approved
          auto_approved_order(@order.id)
        end
     end
       render json:{ status: "Order Placed Successfully"}, status: 200 and return
    rescue => e
      # Handle any exceptions

      message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      return render json: { error: message, app_error: e.message }, status: :unprocessable_entity
      # ensure
      #   return  render json:{ status: "Order Placed Successfully", data: @success_data }, status: 200
    end

  end

  def get_sold_product
    api_data = JSON.parse( params[:data])
    main_entry = ProductEntry.find_by_id(api_data["id"])
    main_enty_units = main_entry.no_of_unit
    main_enty_type = main_entry.product_type.downcase
    return_product =  ReturnedProduct.where(return_order_entry_id: api_data["id"] ).sum(:quantity)

  #  return render json: [main_enty_units,return_product, main_enty_type]
    # checking all stock
      if main_enty_type == 'debit'

      data1 = SoldProduct.where(product_id:api_data["product_id"],order_type: "debit",purchase_unit_price: api_data["unit_price"])
      data1_count = data1.sum(:sold_count)
      data2 = SoldProduct.where(product_id:api_data["product_id"],order_type: "credit",purchase_unit_price: api_data["unit_price"])
      data2_count = data2.sum(:sold_count)
      # return render json: [main_enty_units,return_product, main_enty_type, data1, data2 ]
      elsif  main_enty_type == 'credit'
        data1 = SoldProduct.where(product_id:api_data["product_id"],order_type: "credit",sale_unit_price: api_data["unit_price"])
        data1_count = data1.sum(:sold_count)
        data2 = SoldProduct.where(product_id:api_data["product_id"],order_type: "debit",sale_unit_price: api_data["unit_price"])
        data2_count = data2.sum(:sold_count)
      else
        render json:{ status: "Order Placed Successfully", data: 0 }, status: 200 and return
      end
      # return render json: [main_enty_units,return_product, main_enty_type, all_dr, all_cr ]


      if(data1_count >  data2_count && (main_enty_units - return_product) > 0 )

        d_1_false = data1.where(is_active: false).sum(:sold_count)
        d_1_true = data1.where(is_active: true).sum(:sold_count)

        d_2_false = data2.where(is_active: false).sum(:sold_count)
        d_2_true = data2.where(is_active: true).sum(:sold_count)
        max_product_val = (main_enty_units - return_product)

        # return render json: [max_product_val, d_1_false, d_1_true, d_2_false, d_2_true]

        data_val = (data1_count - data2_count)
        stock_product = data_val > max_product_val ? max_product_val : data_val
        if d_1_false > 0
          stock_product = stock_product - d_1_false
        end
        # temp_products =   data1.where(is_active: false).sum(:sold_count) -  data2.where(is_active: false).sum(:sold_count)
        # render json:{ status: "Order Placed Successfully", data1: [data_val,entry_val,temp_products,stock_product]}, status: 200 and return


        render json:{ status: "Order Placed Successfully", data: stock_product}, status: 200 and return
      else
        render json:{ status: "Order Placed Successfully", data: 0 }, status: 200 and return
      end

    #   return render json: [main_enty_units,return_product, main_enty_type, all_dr, all_cr]


    #   available_product_stock = (all_dr - all_cr)
    # # for purchase
    #   dr_count = SoldProduct.where(product_entries_id: api_data["id"],order_type: "debit",is_active: true).sum(:sold_count)
    #   cr_count = SoldProduct.where(product_entries_id: api_data["id"],order_type: "credit",is_active: true).sum(:sold_count)
    # if api_data["product_type"] == "debit"

    #   main_count = (dr_count - cr_count)
    #   products = available_product_stock < main_count ? available_product_stock : main_count
    #   # render json:{ status: "Order Placed Successfully", data: [available_product_stock,main_count,all_dr,all_cr,dr_count,cr_count] }, status: 200 and return
    #   render json:{ status: "Order Placed Successfully", data: products }, status: 200 and return
    # elsif api_data["product_type"] == "credit"
    #   main_count = (cr_count - dr_count)
    #   render json:{ status: "Order Placed Successfully", data: main_count }, status: 200 and return
    # end

  end

  # def get_sold_product
  #   api_data = JSON.parse( params[:data])
  #   return render json: api_data
  #   # checking all stock
  #     all_dr = SoldProduct.where(product_id:api_data["product_id"],order_type: "debit",purchase_unit_price: api_data["unit_price"],is_active: true).sum(:sold_count)
  #     all_cr = SoldProduct.where(product_id:api_data["product_id"],order_type: "credit",purchase_unit_price: api_data["unit_price"],is_active: true).sum(:sold_count)

  #     available_product_stock = (all_dr - all_cr)
  #   # for purchase
  #     dr_count = SoldProduct.where(product_entries_id: api_data["id"],order_type: "debit",is_active: true).sum(:sold_count)
  #     cr_count = SoldProduct.where(product_entries_id: api_data["id"],order_type: "credit",is_active: true).sum(:sold_count)
  #   if api_data["product_type"] == "debit"

  #     main_count = (dr_count - cr_count)
  #     products = available_product_stock < main_count ? available_product_stock : main_count
  #     # render json:{ status: "Order Placed Successfully", data: [available_product_stock,main_count,all_dr,all_cr,dr_count,cr_count] }, status: 200 and return
  #     render json:{ status: "Order Placed Successfully", data: products }, status: 200 and return
  #   elsif api_data["product_type"] == "credit"
  #     main_count = (cr_count - dr_count)
  #     render json:{ status: "Order Placed Successfully", data: main_count }, status: 200 and return
  #   end

  # end

  # def get_sold_product
  #   api_data = JSON.parse( params[:data])
  #   # return render json: api_data["product_type"]
  #   # checking all stock
  #     all_dr = SoldProduct.where(product_id:api_data["product_id"],order_type: "debit",purchase_unit_price: api_data["unit_price"]).sum(:sold_count)
  #     all_cr = SoldProduct.where(product_id:api_data["product_id"],order_type: "credit",purchase_unit_price: api_data["unit_price"]).sum(:sold_count)

  #     available_product_stock = (all_dr - all_cr)
  #   # for purchase
  #     dr_count = SoldProduct.where(product_entries_id: api_data["id"],order_type: "debit").sum(:sold_count)
  #     cr_count = SoldProduct.where(product_entries_id: api_data["id"],order_type: "credit").sum(:sold_count)
  #   if api_data["product_type"] == "debit"

  #     main_count = (dr_count - cr_count)
  #     products = available_product_stock < main_count ? available_product_stock : main_count
  #     render json:{ status: "Order Placed Successfully", data: products }, status: 200 and return
  #   elsif api_data["product_type"] == "credit"
  #     main_count = (cr_count - dr_count)
  #     render json:{ status: "Order Placed Successfully", data: main_count }, status: 200 and return
  #   end

  # end

  def create_return_order
    begin
       ActiveRecord::Base.transaction do
          # return render json: {data:params}, status: 401
          @order =   Order.new( params.fetch(:data, {}).except(:items, :gst).permit!)
          # @order.invoice_no = "#{Date.today.year}-#{invoice_no}"
          @order.company_id = current_user.company_id
          @order.user_id = current_user.id
          @order.is_igst = Order.find_by_id(params[:data][:items][0][:update_info][:old_order_id]).is_igst
          @order.is_gst_pending = true
          if(@order.save!)
            # return render json:{ data: params}, status: 401
            params[:data][:items].each_with_index do |pro, index|
              @product =  @order.product_entries.new(params[:data].fetch(:items, {})[index].except(:update_info,:return_remarks, :product_type).permit!)
              @product.is_returned = true
              @product.category_id =  pro[:product_description][:product_category_id]
              @product.company_id =  current_user.company_id
              @product.user_id =  current_user.id
              @product.old_order_id =   pro[:update_info][:old_order_id]
              @product.product_type =   @order.order_type.downcase == 'debit' ? "sale return" : "credit"

              # if(@product)
              old_item =  ProductEntry.find_by_id(pro[:update_info][:item])
              if old_item.product_type.downcase == "credit"
                @product.old_unit_price =  old_item.old_unit_price
              end
              @product.p_unit_price_with_discount =   old_item.p_unit_price_with_discount
              @product.net_unit_price =   old_item.net_unit_price

              if(@product.save!)
                @sold = old_item.sold_products.new()
                @sold.entry_type =  old_item.product_type.downcase == "debit" ?  "purchase return" : "sale return"
                @sold.order_type = old_item.product_type.downcase == "debit" ?  "credit" : "debit"
                @sold.product_id = pro[:product_description][:id]
                @sold.sold_count = pro[:no_of_unit]
                @sold.order_id = @order.id
                @sold.mrp = old_item.mrp
                @sold.category_id = pro[:product_description][:product_category_id]
                @sold.company_id = current_user.company_id
                @sold.net_unit_price = @product.net_unit_price
                @sold.returned_entry_id = @product.id
                # @sold.purchase_unit_price = @product.p_unit_price_with_discount.to_f.round(2)
                if old_item.product_type.downcase == "debit"
                  @sold.sale_unit_price = 0
                  @sold.net_unit_price = old_item.net_unit_price.to_f.round(2)
                  @sold.sale_net_unit_price = 0
                  @sold.purchase_unit_price =   old_item.sold_products.where(entry_type: "purchase").first.purchase_unit_price

                elsif old_item.product_type.downcase == "credit"
                  @sold.sale_unit_price = @product.unit_price.to_f.round(2)
                  @sold.net_unit_price = @product.old_unit_price.to_f.round(2)
                  @sold.sale_net_unit_price = @product.net_unit_price.to_f.round(2)
                  @sold.purchase_unit_price =  @product.p_unit_price_with_discount.to_f.round(2)

                end


                # pass time to date
                date = @order.order_date.to_date
                current_time = Time.current
                order_date = DateTime.new(date.year, date.month, date.day, current_time.hour, current_time.min, current_time.sec)
                 # pass time to date
                @sold.transaction_date = order_date

                @sold.is_active = @order.auto_approved == true ? true : false
                @sold.save!

                # update items
                return_track =  @product.returned_products.new()
                return_track.remarks = pro[:return_remarks]
                return_track.quantity = @product.no_of_unit
                return_track.return_order_entry_id = old_item.id
                if return_track.save!
                  # return_Data = old_item.returned_products.sum(:quantity)
                  return_Data  =  ReturnedProduct.where(return_order_entry_id: old_item.id ).sum(:quantity)
                  old_item.update!(
                   old_order_id: pro[:update_info][:old_order_id],
                   returned_qty: return_Data,
                   is_returned: return_Data >= old_item.no_of_unit ? true : false
                  )
                end
              end
            end
            if @order.order_type.downcase == 'debit' && @order.is_returned == true
                # sale_return_order(@order)
                sale_return_order_controller(@order)
                ::Order.update_sale_return_order_total(@order.id)
            else
              ::Order.update_order_total(@order.id)
            end

          else
            raise ActiveRecord::Rollback
          end




        # return render  json: {data: @order.id}, status: 401
        # update_order_total(@order.id)

      end
        render json:{ status: "Order Placed Successfully", data: @order }, status: 200 and return
      rescue => e
          # Handle any exceptions
          message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
          render json: { error: message, app_error: e.message, error_e: e }, status: :unprocessable_entity
      end
  end
  def model_params
    params.fetch(:store, {}).permit!
  end
  def model_params_order
    params.fetch(:data, {}).except(:items,:bill_calculations, :credit_from,:services_items,:assets).permit!
  end
  # Api::V1::StoreController.approve_bill
  def approve_bill
    # return render  json: params[:data][:type] == 'reject', status: 401
    begin
      ActiveRecord::Base.transaction do
        if params[:data][:type] == 'reject'
          order =  Order.find_by_id(params[:data][:id])
          order.product_entries.each do |t|
             SoldProduct.where(order_id: t.order_id).each do |d|
              d.destroy!
            end

            t.update(availablity: "rejected")

          end
          order.update(status: "rejected")
        else
          auto_approved_order(params[:data][:id])
        end

      end
      # raise ActiveRecord::Rollback
      render json:{ status: "Action performed successfully" }, status: 200 and return
    rescue => e
      # Handle any exceptions

      message ="Somthing want wrong"
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    # ensure
    #   # Cleanup code that runs whether or not the transaction is successful
    #   cleanup_task
    end
  end
  def auto_approved_order(id)
    # puts "wwww #{id}"
    find_order = Order.find_by_id(id)
      if(find_order.order_type.downcase == 'debit' && find_order.is_returned == true)
        order = Order.where("id =? or parent_order_id =?",  id, id)
      else
        order = Order.where("id =?",  id)
      end
      # puts "aaaaa #{order.count}"
      order.each do |o|
        o.product_entries.each {|t| t.update(is_processed: true)}
        if(o.order_type.downcase == 'debit' && o.is_returned == false )
          o.update(invoice_no: "PUR-#{o.order_date.year}-#{invoice_no(false, 'debit',o.order_date)}")
        elsif(o.order_type.downcase == 'credit'  && o.is_returned == false)
          o.update(invoice_no: "SALE-#{o.order_date.year}-#{invoice_no(false, 'credit',o.order_date)}")
        elsif(o.order_type.downcase == 'credit'  && o.is_returned == true)
          o.update(invoice_no: "PUR-R-#{o.order_date.year}-#{invoice_no(true, 'credit',o.order_date)}")
        elsif(o.order_type.downcase == 'debit'  && o.is_returned == true)
          o.update(invoice_no: "SALE-R-#{o.order_date.year}-#{invoice_no(true, 'debit',o.order_date)}")
        end
        o.update(auto_approved: true, is_processed: true)
        SoldProduct.where(order_id:o.id).update_all(is_active: true);
        Accounting::Order.approve_order(o.id)
      end
  end
  def edit_order_with_detail
    # begin
      @order =  Order.find_by_slug(params[:slug])
      if(@order.present?)
          # total_amt =  @user.promoters.balance_available(current_user.company_id)
          render json:{ status: "success dfsd", data: @order,khata: @order.khatabook, services:@order.sale_service_transactions ,product:@order.product_entries,assets: @order.fixed_assets }, status: 200 and return
      else
        render json: { err_message: "User or promoters not found" }, status: :not_found
      end
    # rescue => exception
    #   Rails.logger.error("Error fetching user: #{exception.message}")
    #   render json: { err_message: "Something went wrong", error: exception.message }, status: :internal_server_error
    # end
  end







    #       # order = Order.find_by_id(178)
    #   order.product_entries.each {|t| t.update(is_processed: true)}
    #   order.update(auto_approved: true, is_processed: true)
  def remove_sale_edit_product
    begin
      ActiveRecord::Base.transaction do
        @product = ProductEntry.find_by_slug!(params[:slug]) # Use `find_by_slug!` for exceptions on nil
        order_id = @product.order_id
        @product.sold_products.where(entry_type: "sale").each {|d| d&.destroy!} # Simplifies the loop
        @product&.destroy! # If this fails, an exception is raised automatically

        ::Order.update_order_total(order_id)
      end
      render json: { message: "Success" }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Product not found." }, status: :ok
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end
  def add_product_items_sale_edit
    begin
      ActiveRecord::Base.transaction do
        @order = Order.find_by_slug(params[:order_slug])
        product = params[:data]
        # return render json: {data: @order}, status: 401
        sale_net_u_price  =  ((product[:unit_price]).to_f.round(2) - ( product[:unit_price] * ((params[:form_data][:discount_percent]).to_f.round(2)) / 100) ).to_f.round(2)
        @order.update!(discount_percent: params[:form_data][:discount_percent], round_off_amount: params[:form_data][:round_off_amt]  )

        product_id = product[:product_description][:id]
        @item =  @order.product_entries.new(params.fetch(:data, {}).except(:gst_percent,:purchase_unit_price,:name).permit!)
        @item.product_id = product_id
        @item.old_unit_price = product[:purchase_unit_price]
        @item.company_id = current_user.company_id
        @item.product_description = product[:product_description]
        @item.user_id = current_user.id
        @item.availablity = "notavailable"

        @item.net_unit_price = sale_net_u_price
        @item.p_unit_price_with_discount = params[:form_data][:unit_price_with_discount]
        @item.product_type = "credit"
        if @item.save!
          date = @order.order_date.present? ? @order.order_date.to_date : Date.today
          current_time = Time.current
          order_date = DateTime.new(date.year, date.month, date.day, current_time.hour, current_time.min, current_time.sec)

          @sold = @item.sold_products.create!(
            entry_type: "sale",
            order_type: "credit",
            product_id: product_id,
            order_id: @item.order_id,
            sold_count: product[:no_of_unit],
            mrp: @item.mrp,
            company_id: current_user.company_id,
            sale_unit_price: @item.unit_price.to_f,
            purchase_unit_price:params[:form_data][:unit_price_with_discount].to_f,
            net_unit_price: product[:purchase_unit_price],
            transaction_date: order_date.to_date,
           category_id: product[:product_description][:product_category_id],
            sale_net_unit_price: sale_net_u_price,
            is_active: @order.auto_approved == true ? true : false
          )
        else
         raise ActiveRecord::Rollback
        end
      end
      @order.paid_from.nil? ? ::Order.update_order_total(@order.id)  : Order.update_order_total(@order.id, @order.paid_from)
      # update_order_total(@order.id, @order.paid_from)
      render json: { message: "Success", services: @order.sale_service_transactions, product: @order.product_entries }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Product not found." }, status: :not_found
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end

  def save_edit_sale_order
    # return render json: { data: params[:data], status: "Order Placed Successfully"}, status: 401
    begin
      ActiveRecord::Base.transaction do
        apidat = params[:data]
        order_date = (apidat[:order_date].to_datetime + 6.hours).to_date

        # return render json: apidat[:discount_percent]
        @order = Order.find_by_slug(params[:order_slug])
        @order_update = @order.update!(
          ack_no: apidat[:ack_no],
          auto_approved: apidat[:auto_approved],
          irn_no: apidat[:irn_no],
          khatabooks_id: apidat[:khatabooks_id],
          discount_percent: apidat[:discount_percent],
          mobile_no: apidat[:mobile_no],
          vechile_no: apidat[:vechile_no],
          user_id: current_user.id,
          company_id: current_user.company_id,
          round_off_amount: apidat[:bill_calculations][:round_off_amount],
          discount: apidat[:bill_calculations][:grand_discount],
          paid_from: apidat[:paid_from],
        )
        unless @order_update
          raise ActiveRecord::Rollback
        end

        @order.product_entries.each do |e|
          e.update!(availablity: "available")
        end
      #  return render json: @order_update
       @o_services = @order.sale_service_transactions
        @live_service =  params[:data][:services_items]

        @saved_service_ids =  @o_services.map{|i|i[:id] }.compact
        @live_service_ids_old =  @live_service.map{|i|i[:id] }.compact
        @live_service_ids_new =  []
        @live_service.map do |i|
          if i[:id].nil?
            @live_service_ids_new << i
          end
        end
        unavilable_ids = (@saved_service_ids - @live_service_ids_old) + (@live_service_ids_old - @saved_service_ids)
        # destroy unwanted services
        unavilable_ids.each{|s| SaleServiceTransaction.find_by_id(s).destroy!}
        # update and create new services
        @live_service.each_with_index do |ser, index|
          if ser[:id].present?
            SaleServiceTransaction.find_by_id(ser[:id]).update!(
              khatabook_id: params[:data][:khatabooks_id]
            )
          else
              @service = @order.sale_service_transactions.new(apidat.fetch(:services_items, {})[index].except(:choose_service,:t_date,:gst_percent ).permit!)
              @service.company_id = current_user.company_id
              @service.user_id = current_user.id
              @service.t_date = order_date
              @service.khatabook_id = params[:data][:khatabooks_id]
              @service.service_type = "debit"
             if @service.save!
             else
              raise ActiveRecord::Rollback
             end

          end
        end
        ::Order.update_order_total(@order.id, @order.paid_from)
        if @order.auto_approved
          auto_approved_order(@order.id)
        end
     end
       render json:{ status: "Order Placed Successfully"}, status: 200 and return
    rescue => e
      # Handle any exceptions

      message ="We're sorry, but your order could not be placed at this time. Please try again later or contact support if the issue persists."
      return render json: { error: message, app_error: e.message }, status: :unprocessable_entity
      # ensure
      #   return  render json:{ status: "Order Placed Successfully", data: @success_data }, status: 200
    end

  end


  # private
  def invoice_no(is_returned,order_type,date)
    f_year = financial_year(date)
    count_orders = Order.where(order_type: order_type,is_returned: is_returned, order_date: "01-04-#{f_year[0]}".."31-03-#{f_year[1]}" ).where.not(invoice_no: nil).count
     order_no = ''
      if count_orders
        count_orders += 1

        order_no = "#{count_orders.to_s.rjust(3, '0')}"

          # if(count_orders < 9)
          #   order_no = "00#{count_orders}"
          # elsif count_orders < 99
          #   order_no = "0#{count_orders}"
          # else
          #   order_no = "#{count_orders}"
          # end
      end

  end

  def financial_year(date)
    start_year = date.month >= 4 ? date.year : date.year - 1
    end_year = start_year + 1
    # "#{start_year}-#{end_year}"
    return [start_year,end_year]
  end
  # Api::V1::StoreController.test
  def order_balance_checking(company_id, order)

    # Order.first.paid_from
    liquid_balace_errors = []
    # low_bal_checking
    o_paid_from = order['paid_from']
    # debtor = o_paid_from.filter{|key| key['is_debtor'] == true }
    liquid = o_paid_from.filter{|key| key['is_debtor'] == false  }
    liquid.each do |item|
      comp_ledger = "#{item['name'].split(" ").join("_")}_#{company_id}"
      coming_amount = item['value'].to_f.round(2)
      l_balance = Plutus::Account.find_by_name(comp_ledger).balance.to_f.round(2)
      if l_balance < coming_amount
      # if 11 < coming_amount
        liquid_balace_errors << "Low #{item['name']} balance Rs. #{l_balance}. Enter amount for #{item['name']} is #{coming_amount}. Enter vaild Amount "
      end
    end
    # low_bal_checking_end
    order_total = order[:bill_calculations][:grand_total].to_f.round(2)
    order_sum = []
    mismatch_bal_text = ""
    o_paid_from.each do |b|
       order_sum << b[:value].to_f.round(2)
       mismatch_bal_text << "#{b[:name]} : #{b[:value].to_f.round(2)}, "
    end
    unless order_total == order_sum.sum.to_f.round(2)
      liquid_balace_errors << "#{mismatch_bal_text} Paying: #{order_sum.sum.to_f.round(2)}, Payable : #{order_total}.Entered amount mismatched check again"
    end
    return  liquid_balace_errors
  end
  # Api::V1::StoreController.sale_return_order_controller
  # def sale_return_order(s_return_order)
  def sale_return_order_controller(s_return_order)
      # s_return_order = Order.find_by_id(205)
      s_return_order.product_entries.where(product_type: 'debit').each {|e| e&.destroy!}
      data = []
      s_return_order.product_entries.each {|d| data.push(d)}
      data.each do |e|
        #  return puts  "dfsdfsdf"
       @new_e =  s_return_order.product_entries.new(e.attributes.except("id", "is_returned", "order_id", "old_order_id", "return_remarks"))
      #  @new_e.order_id = @order.id
       @new_e.unit_price = e.old_unit_price.to_f
       @new_e.net_unit_price = e.old_unit_price.to_f
       @new_e.product_type = 'debit'
        # calculations
           total_unit_price_without_gst =   (e.no_of_unit * e.old_unit_price.to_f.round(2) )
           gst_amt =   total_unit_price_without_gst * (e.product_description["gst"].to_f) / 100
           total = total_unit_price_without_gst + gst_amt
        # calculations
        @new_e.gst = gst_amt
        @new_e.total = total
      @new_e.save!
    end
  end
end

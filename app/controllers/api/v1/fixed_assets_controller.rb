class Api::V1::FixedAssetsController < ApplicationController
  before_action :authenticate_user!
  require 'json'
  require 'pagy/extras/jsonapi'
  def all_fixed_assets
    begin
      items_per_page = 50
      params[:page].present? &&  params[:page].to_i != 0 ? page = params[:page].to_i : page=  1
      # @pagy, @paginated_khatabook  = pagy(@data, items: items_per_page, page:page)

      @data = FixedAsset.joins(:order)
      .where(orders: { status: "processed" })
      .select('fixed_assets.*, orders.slug AS order_slug', 'orders.order_date')
      balance = Plutus::Account.find_by_name("fixed_assets_#{current_user.company_id}").balance

      @pagy, @paginated_data  = pagy(@data, items: items_per_page, page:page)
      if @paginated_data.present?
          render json:{ status: "Bind Successfully", data: @paginated_data, pagination: @pagy, balance: balance }, status: 200 and return
      else
        render json:{ status: "No data"}, status: 204 and return
      end
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end
  def fixed_assets_sale
    begin
      # items_per_page = 50
      # params[:page].present? &&  params[:page].to_i != 0 ? page = params[:page].to_i : page=  1
      # @pagy, @paginated_khatabook  = pagy(@data, items: items_per_page, page:page)
      #   d = []
      #   FixedAsset.each do |f|
      #     dr  = f.record_fixed_assets.where(assets_type: "debit").sum(:no_of_unit)
      #     cr  = f.record_fixed_assets.where(assets_type: "credit").sum(:no_of_unit)
      #     if (dr - cr) > 0
      #     end
      #   end

      # @data = FixedAsset.where(assets_type: 'debit')
      #         .joins(:order)
      #         .where(orders: { status: "processed" })
      #         .select('fixed_assets.*', 'orders.order_date')
      @data = []
      @fixed_Asset = FixedAsset
      .joins(:order)
      .joins("LEFT JOIN record_fixed_assets ON record_fixed_assets.fixed_asset_id = fixed_assets.id")
      .where(assets_type: 'debit')
      .where(orders: { status: "processed" })
      .select(
        'fixed_assets.*',
        'orders.order_date',
        'SUM(CASE WHEN record_fixed_assets.assets_type = \'debit\' THEN record_fixed_assets.no_of_unit ELSE 0 END) AS dr',
        'SUM(CASE WHEN record_fixed_assets.assets_type = \'credit\' THEN record_fixed_assets.no_of_unit ELSE 0 END) AS cr'
      )
      .group('fixed_assets.id, orders.order_date')
      .having('SUM(CASE WHEN record_fixed_assets.assets_type = \'debit\' THEN record_fixed_assets.no_of_unit ELSE 0 END) -
               SUM(CASE WHEN record_fixed_assets.assets_type = \'credit\' THEN record_fixed_assets.no_of_unit ELSE 0 END) > 0')
               @fixed_Asset.each do |f|
                if (f.dr - f.cr) > 0
                  @data << f
                end
               end
    render json:{ status: "Bind Successfully", data: @data }, status: 200 and return
      # if @data.present?
      #     render json:{ status: "Bind Successfully", data: @data }, status: 200 and return
      # else
      #   render json:{ status: "No data", data: @data }, status: 204 and return
      # end
    rescue => e
      # Handle any exceptions
      message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
      render json: { error: message, app_error: e.message }, status: :unprocessable_entity
    end
  end
   def fixed_assets_sale_save
    # return render  json: {data: params[:order_slug]}
    begin
      ActiveRecord::Base.transaction do
        @order = Order.find_by_slug(params[:order_slug])
        if @order.present?
          # return render json: {data: params[:asset]}, status: 401
          gst_amount = (params[:asset][:unit_amount].to_f.round(2) * params[:asset][:no_of_unit].to_f.round(0) )* params[:asset][:gst].to_f.round(2) / 100
          @assets = @order.fixed_assets.new(params.fetch(:asset, {}).except(:taxable,:id, :refrence_id).permit!)
          @assets.assets_type = "credit"
          @assets.gst_amount = gst_amount
          @assets.total = gst_amount + (params[:asset][:unit_amount].to_f.round(2) * params[:asset][:no_of_unit].to_f.round(0))
          if @assets.save!
            @record = @assets.record_fixed_assets.new
              @record.assets_type = @assets.assets_type
              @record.no_of_unit = @assets.no_of_unit
              @record.unit_amount = @assets.unit_amount
              if @record.save!
                old_asset = FixedAsset.find_by_id(params[:asset][:refrence_id])
                @record_old  = old_asset.record_fixed_assets.new
                  @record_old.assets_type = @assets.assets_type
                  @record_old.no_of_unit = @assets.no_of_unit
                  @record_old.unit_amount = @assets.unit_amount
                  @record_old.refrence_id = @assets.id
                  @record_old.save!
              end
          end
        end

      end
      render json:{ status: "Bind Successfully", data: @assets}, status: 200 and return
    rescue StandardError => e
      render json: { err_message: "Somthing want wrong", error: e.message}, status: 401 and return
    end

   end
   def delete_fixed_assets_sale
    begin
      ActiveRecord::Base.transaction do
        RecordFixedAsset.find_by_refrence_id(params[:id])&.destroy!
        fixed_entry = FixedAsset.find_by_id(params[:id])
        fixed_entry.record_fixed_assets.each{|fe| fe&.destroy!}
        fixed_entry&.destroy!
      end
      render json:{ status: "Deleted Successfully"}, status: 200 and return
    rescue StandardError => e
      render json: { err_message: "Somthing want wrong", error: e.message}, status: 401 and return
    end

   end
end

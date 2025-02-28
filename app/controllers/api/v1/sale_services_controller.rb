class Api::V1::SaleServicesController < ApplicationController
  before_action :authenticate_user!
  require 'json'
  require 'pagy/extras/jsonapi'
  def index
    @categories = SaleService.where(company_id: current_user.company_id).order(id: :desc)
    if  @categories.present?
      render json:{ status: "Bind Successfully", data: @categories }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end
  def get_sale_services_active
    @categories = SaleService.where(company_id: current_user.company_id, is_active: true ).order(id: :desc)
    if  @categories.present?
      render json:{ status: "Bind Successfully", data: @categories }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end




  def create
    @cat =   SaleService.where(name: (params[:data][:name]).strip, company_id: current_user.company_id)
    if @cat.present?
     render json: { error: "Duplicate Service Name"}, status: 401 and return
    end
     begin
       ActiveRecord::Base.transaction do
         @newcat =  SaleService.new(params.fetch(:data, {}).permit!)
         @newcat.company_id = current_user.company_id
         @newcat.user_id = current_user.id
         @newcat.save!
       end
       render json: { status: "Saved Successfully" }, status: :ok and return
     rescue => e
       # Handle any exceptions
       message = "We're sorry, but the transaction could not be saved at this time. Please try again later or contact support if the issue persists."
       render json: { error: message, app_error: e.message }, status: :unprocessable_entity
     end
  end
  def update
    @cat =  SaleService.find_by_id(params[:id])
    if @cat.present?
      @cat.update(is_active: !@cat.is_active)
      render json:{ status: "Update Successfully", data: @cat }, status: 200 and return
    else
      render json: { error: "Data not found"}, status: 401 and return
    end
  end
end

class ApplicationController < ActionController::API
  # protect_from_forgery with: :exception
  before_action :switch_tenant
  before_action :configure_permitted_parameters, if: :devise_controller?
  protected

  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar])
    # devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])

       devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit( :email, :password, :f_name, :l_name, :is_active, :company_id )}
       devise_parameter_sanitizer.permit(:account_update) { |u| u.permit( :email, :password, :f_name, :l_name, :is_active, :company_id)}
  end
  def switch_tenant
    puts "switch_tenant"
    company_name = request.headers["Company-Name"] # Pass Company-Name in Angular API request
    puts "Switching tenant...to #{company_name}"
    company = CompanyLogin.find_by(company_name: company_name)
    # return render  json: ActiveRecord::Base.connection.current_database
    # return render  json: company
    if company
      TenantService.switch(company)
    else
      return false
    end

  end
end

class ApplicationController < ActionController::API
  # protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar])
    # devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])

       devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit( :email, :password, :f_name, :l_name, :is_active, :company_id )}
       devise_parameter_sanitizer.permit(:account_update) { |u| u.permit( :email, :password, :f_name, :l_name, :is_active, :company_id)}
  end
end

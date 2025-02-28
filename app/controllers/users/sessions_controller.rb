# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # def create
  #   # response.headers['Access-Control-Expose-Headers'] = 'Authorization'
  #   # Access-Control-Expose-Headers: Authorization
  # end
  def create
    new_login = params[:user][:email]
    User.find_by_email(new_login).update(jti: SecureRandom.uuid)
    super do |user|
      if user.persisted?
        invalidate_old_tokens(user)
      end
    end
  end
 def destroy
  # return render json: "sdfsdfsdf s"
 end
  private
  def respond_with(resource, options={})

    response.headers['Access-Control-Expose-Headers'] = 'Authorization'
    render json:{
      status: {
        code: 200,
        message: "User Signin Successfully",
        data: UserSerializer.new(current_user).serializable_hash[:data][:attributes],

      }
    }
  end
  def respond_to_on_destroy
    # jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.credentials.secret_key_base ).first
    # current_user = User.find(jwt_payload['sub'])

    if request.headers['Authorization'].present?

      # return render json: JWT.decode(request.headers['Authorization'])

      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[1], Rails.application.credentials.devise_jwt_secret_key!).first
      current_user = User.find(jwt_payload['sub'])
    end

    if( current_user)
      render json: {
        status: 200,
        message: "Signout Successfully",

      }
      else
        render json:{
          status: 401,
          message: "User has no active session"
        }
        # render json:{ status: "ERROR", message: "User has no active session" }, status: 401 and return
    end

  end

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params

    # devise_parameter_sanitizer.permit(:sign_in, keys: [:f_name, :l_name, :role])
    # def configure_permitted_parameters
      # devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :f_name,  :l_name, :role) }
      # devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password,  :current_password, :f_name,  :l_name, :role) }
    # end
  # end
  def invalidate_old_tokens(user)
    # respond_to_on_destroy
    # user.update(jti:"dfdfd")
    # Implement token invalidation logic here
    # For example, mark old tokens as invalid in your database
  end

end

# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController

  respond_to :json
  #  before_action :configure_sign_up_params, only: [:create]
  # def create
  #     # return render json: params
  # end
  private
  def respond_with( resource, options ={})

    if resource.persisted?
      render json: {
        code: 200,
        message: " User SignedIn Successfully",
        data: resource
      }
    else
      render json:{
        status:{
          message: "Unable to create this user",
          errors: resource.errors.full_messages,
          code: 404
        }
      }
    end
  end
end

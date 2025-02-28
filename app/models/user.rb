

class User < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]

  # Include default devise modules. Others available are:
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :company
  has_and_belongs_to_many :roles
  has_many :promoters



  def state_gst_id
    company.state_gst_id
  end

  def as_json(options = {})
    super(options).merge(state_gst_id: state_gst_id)
  end



  def jwt_payload
     super
  end

  def slug_method
    [ ]
  end

  def user_roles
    roles
  end

  def as_json(options = {})
    super(options).merge(roles: user_roles)
  end






  # User.admin_user((company_id, f_name, l_name, email, pass))
  def self.admin_user(company_id, f_name, l_name, email, pass)
    data =  self.create(
      f_name: f_name,
      l_name: l_name,
      email: email,
      password: pass,
      is_active: true,
      company_id: company_id

    )
    return puts data.save!
  end

end

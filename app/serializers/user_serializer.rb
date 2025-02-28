class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :f_name, :l_name, :company_id, :state_gst_id
end

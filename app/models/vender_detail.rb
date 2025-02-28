class VenderDetail < ApplicationRecord
  has_many :orders, foreign_key: 'vender_id'

end

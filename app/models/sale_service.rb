class SaleService < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]
  has_one :sale_service_transaction
  def slug_method
    [ ]
  end
end

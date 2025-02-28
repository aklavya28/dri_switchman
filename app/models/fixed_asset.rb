class FixedAsset < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]
  belongs_to :order
  has_many :record_fixed_assets
  def slug_method
    [ ]
  end

end

class KhataTransaction < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]
  belongs_to :khatabook

  def slug_method
    [ ]
  end
end

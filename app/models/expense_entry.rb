class ExpenseEntry < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]


  def slug_method
    [ ]
  end
end

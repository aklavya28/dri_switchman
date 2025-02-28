class ProductEntry < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]
  belongs_to :product_category, foreign_key: 'category_id'
  belongs_to :order
  belongs_to :product
  has_many :sold_products,foreign_key: 'product_entries_id'
  has_many :returned_products

  def slug_method
    [ ]
  end
end

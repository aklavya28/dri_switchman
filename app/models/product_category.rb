class ProductCategory < ApplicationRecord
  belongs_to :user
  belongs_to :company
  has_many :products
  has_many :product_entry

end

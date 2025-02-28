class Product < ApplicationRecord
  belongs_to  :product_category
  has_one  :product_entry
end

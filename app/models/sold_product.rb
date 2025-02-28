class SoldProduct < ApplicationRecord
  # belongs_to :product_entries
  belongs_to :product_entry,foreign_key: 'product_entries_id'
end

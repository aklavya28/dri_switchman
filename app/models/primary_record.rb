class PrimaryRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { primary: :primary }
end

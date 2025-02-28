class AdvanceSalary < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]

  belongs_to :employee
  has_many :advance_salary_payouts, foreign_key: 'advance_salaries_id'



  def slug_method
    [ ]
  end
end

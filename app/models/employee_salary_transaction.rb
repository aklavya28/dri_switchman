class EmployeeSalaryTransaction < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]

  # belongs_to :employee_salary
    belongs_to :employee


  def slug_method
    [ ]
  end
end

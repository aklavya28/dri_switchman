class EmployeeSalary < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]

  has_many :employee_salary_transactions, :foreign_key => 'employee_salaries_id'



  def slug_method
    [ ]
  end
end

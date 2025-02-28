class AdvanceSalaryPayout < ApplicationRecord
  belongs_to :advance_salary, optional: true
end

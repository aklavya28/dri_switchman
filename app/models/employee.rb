class Employee < ApplicationRecord
  # attr_accessor :extra_column

  # def as_json(options = {})
  #   super(options).merge(extra_column: extra_column)
  # end
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]
  has_many :employee_salary_transactions
  has_many :advance_salary

  has_many :advance_salary_payouts, :foreign_key => 'emp_id'

  def panding_installment
    advance_salary_payouts.where("is_paid =?", false).first
  end

  def as_json(options = {})
    super(options).merge(panding_installment: panding_installment)
  end

  def slug_method
    [ ]
  end
end

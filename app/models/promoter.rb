class Promoter < ApplicationRecord
  belongs_to :user
  scope :not_allocated, -> { where( payment_status: "success") }
  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]

  def slug_method
    [ ]
  end

  # Promoter.balance_available
  def self.balance_available(company_id)
    @credit =  Promoter.where(transaction_type:"credit", company_id: company_id).sum(:amount).to_f.round(2)
    @debit =  Promoter.where(transaction_type:"debit", company_id: company_id).sum(:amount).to_f.round(2)
    @credit - @debit
  end

end

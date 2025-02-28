class SaleServiceTransaction < ApplicationRecord
  belongs_to :order
  belongs_to :sale_service

  def as_json(options = {})
    super(options).merge(sale_service: sale_service)
  end

end

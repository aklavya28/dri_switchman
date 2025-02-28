class Khatabook < ApplicationRecord

  extend FriendlyId
  friendly_id :slug_method, use: [:slugged, :finders]
  after_create :update_status_if_state_id_blank
  # validates :pan, presence: true, uniqueness: true
  has_many :khata_transactions

  has_many :orders, foreign_key: 'khatabooks_id'
  def slug_method
    [ ]
  end
  private

  def update_status_if_state_id_blank
    # puts  "testeme #{self.inspect}"
    if self.state_id.nil?
      id = Company.find_by_id(self.company_id).state_gst_id;
      update(state_id: id) # Replace "pending" with the desired default status
    end
  end



end

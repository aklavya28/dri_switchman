class Role < ApplicationRecord
  has_and_belongs_to_many :users, dependent: :destroy
  @@predefinedroles = ['SuperAdmin', 'Accountent', 'Promoter' ].freeze
  # Role.new_role
  def self.new_role
    data = []
    @@predefinedroles.each do |r|
      data << self.create(
        name: r
      )
    end
   return puts data
  end


end

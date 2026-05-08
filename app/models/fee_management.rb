class FeeManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Fee Management') do |fm|
      fm.description = 'Manage all fee records including fee types, fee assignments, and payment tracking.'
    end
  end
end
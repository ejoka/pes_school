class FeeManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Fee Management') do |fm|
      fm.description = 'Manage all fee records including fee categories, fee assignments, payments, and invoice generation.'
    end
  end
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'FeeManagement').pluck(:resource_id))
  end
end
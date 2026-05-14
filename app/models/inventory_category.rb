class InventoryCategory < ApplicationRecord
  has_many :inventory_items, dependent: :restrict_with_error
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: true
  
  scope :ordered, -> { order(:name) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'InventoryCategory').pluck(:resource_id))
  end
end
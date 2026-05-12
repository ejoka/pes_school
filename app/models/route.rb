class Route < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: true
  validates :fare, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :ordered, -> { order(:name) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'Route').pluck(:resource_id))
  end
  
  def formatted_fare
    "$#{fare.to_i}"
  end
end
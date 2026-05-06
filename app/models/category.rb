class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :classes, dependent: :destroy
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'Category').pluck(:resource_id))
  end
end
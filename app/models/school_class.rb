class SchoolClass < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :category_id }
  validates :pass_mark, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  belongs_to :category
  has_many :subjects, dependent: :destroy
  has_many :students, dependent: :restrict_with_error 
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'SchoolClass').pluck(:resource_id))
  end
end
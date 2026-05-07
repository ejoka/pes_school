class StudentManagement < ApplicationRecord
  # This model represents the student management resource
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  # Create default record if none exists
  def self.default
    find_or_create_by(name: 'Student Management') do |sm|
      sm.description = 'Manage all student records including personal information, parent/guardian details, and class assignments.'
    end
  end

  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'StudentManagement').pluck(:resource_id))
  end
end
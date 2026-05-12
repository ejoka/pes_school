class ExamManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Exam Management') do |em|
      em.description = 'Manage exam grades, exam types, and examination settings.'
    end
  end
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'ExamManagement').pluck(:resource_id))
  end
end
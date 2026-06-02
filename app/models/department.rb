class Department < ApplicationRecord
  has_many :staff_assignments, dependent: :destroy
  has_many :users, through: :staff_assignments
  belongs_to :hod, class_name: 'User', optional: true
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  
  scope :ordered, -> { order(:name) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'Department').pluck(:resource_id))
  end
  
  def hod_name
    hod&.full_name || 'Not assigned'
  end
  
  def staff_count
    staff_assignments.active.count
  end
end
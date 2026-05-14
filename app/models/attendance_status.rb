class AttendanceStatus < ApplicationRecord
  has_many :attendance_records, dependent: :restrict_with_error
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'AttendanceStatus').pluck(:resource_id))
  end
end
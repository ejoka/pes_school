class AttendanceRecord < ApplicationRecord
  belongs_to :student
  belongs_to :school_class
  belongs_to :attendance_status, optional: true  # Changed from status
  belongs_to :user, optional: true
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :date, presence: true
  validates :student_id, uniqueness: { scope: [:date, :school_class_id], message: "already has attendance recorded for this date" }
  
  scope :for_date, ->(date) { where(date: date) }
  scope :for_class, ->(class_id) { where(school_class_id: class_id) }
  scope :for_week, ->(date) { where(date: date.beginning_of_week..date.end_of_week) }
  scope :present, -> { joins(:attendance_status).where(attendance_statuses: { code: 'P' }) }
  scope :absent, -> { joins(:attendance_status).where(attendance_statuses: { code: 'A' }) }
  scope :late, -> { joins(:attendance_status).where(attendance_statuses: { code: 'L' }) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'AttendanceRecord').pluck(:resource_id))
  end
  
  def status_color
    attendance_status&.color || 'bg-gray-100 text-gray-800'
  end
  
  def status_name
    attendance_status&.name || 'Not Marked'
  end
  
  def status_code
    attendance_status&.code || '—'
  end
  
  def recorded_by_name
    user&.full_name || 'System'
  end
end
class StaffAttendanceRecord < ApplicationRecord
  belongs_to :staff_assignment
  belongs_to :staff_attendance_status, optional: true  # Changed from status
  belongs_to :recorded_by, class_name: 'User', optional: true
  
  validates :date, presence: true
  validates :staff_assignment_id, uniqueness: { scope: :date, message: "already has attendance recorded for this date" }
  
  scope :for_date, ->(date) { where(date: date) }
  scope :for_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }
  scope :present, -> { joins(:staff_attendance_status).where(staff_attendance_statuses: { code: 'P' }) }
  scope :absent, -> { joins(:staff_attendance_status).where(staff_attendance_statuses: { code: 'A' }) }
  scope :late, -> { joins(:staff_attendance_status).where(staff_attendance_statuses: { code: 'L' }) }
  scope :leave, -> { joins(:staff_attendance_status).where(staff_attendance_statuses: { code: 'LV' }) }
  
  def status_color
    staff_attendance_status&.color || 'bg-gray-100 text-gray-800'
  end
  
  def status_name
    staff_attendance_status&.name || 'Not Marked'
  end
  
  def formatted_check_in
    check_in_time&.strftime("%I:%M %p") if check_in_time
  end
  
  def formatted_check_out
    check_out_time&.strftime("%I:%M %p") if check_out_time
  end
end
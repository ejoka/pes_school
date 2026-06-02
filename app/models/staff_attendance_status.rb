class StaffAttendanceStatus < ApplicationRecord
  has_many :staff_attendance_records, dependent: :restrict_with_error
  
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  
  STATUSES = [
    { name: 'Present', code: 'P', color: 'bg-green-100 text-green-800' },
    { name: 'Absent', code: 'A', color: 'bg-red-100 text-red-800' },
    { name: 'Late', code: 'L', color: 'bg-yellow-100 text-yellow-800' },
    { name: 'Leave', code: 'LV', color: 'bg-blue-100 text-blue-800' },
    { name: 'Half Day', code: 'HD', color: 'bg-purple-100 text-purple-800' },
    { name: 'Holiday', code: 'H', color: 'bg-gray-100 text-gray-800' }
  ].freeze
  
  def self.seed_statuses
    STATUSES.each do |status|
      find_or_create_by(code: status[:code]) do |s|
        s.name = status[:name]
        s.color = status[:color]
      end
    end
  end
end
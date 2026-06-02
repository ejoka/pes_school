class StaffAttendanceManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Staff Attendance Management') do |sam|
      sam.description = 'Manage staff attendance, leave requests, and attendance reports.'
    end
  end
end
class AttendanceManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Attendance Management') do |am|
      am.description = 'Manage student attendance records, track presence/absence, and generate attendance reports.'
    end
  end
end
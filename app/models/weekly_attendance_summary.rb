class WeeklyAttendanceSummary < ApplicationRecord
  belongs_to :student
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :week_starting, presence: true
  validates :student_id, uniqueness: { scope: :week_starting, message: "already has summary for this week" }
  
  scope :for_week, ->(date) { where(week_starting: date.beginning_of_week) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'WeeklyAttendanceSummary').pluck(:resource_id))
  end
end
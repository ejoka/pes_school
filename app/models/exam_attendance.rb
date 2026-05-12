class ExamAttendance < ApplicationRecord
  belongs_to :student
  belongs_to :school_class
  belongs_to :subject
  belongs_to :exam_schedule
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :student_id, uniqueness: { scope: [:exam_schedule_id], message: "already has attendance recorded for this exam" }
  validates :status, presence: true, inclusion: { in: %w[present absent] }
  
  STATUSES = {
    'present' => 'Present',
    'absent' => 'Absent'
  }.freeze
  
  scope :present, -> { where(status: 'present') }
  scope :absent, -> { where(status: 'absent') }
  scope :by_exam, ->(exam_schedule_id) { where(exam_schedule_id: exam_schedule_id) }
  scope :by_class, ->(class_id) { where(school_class_id: class_id) }
  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'ExamAttendance').pluck(:resource_id))
  end
  
  def status_badge_color
    case status
    when 'present'
      'bg-green-100 text-green-800'
    else
      'bg-red-100 text-red-800'
    end
  end
  
  def status_icon
    case status
    when 'present'
      '✓'
    else
      '✗'
    end
  end
end
class ExamSchedule < ApplicationRecord
  belongs_to :subject
  belongs_to :school_class
  belongs_to :exam_type
  belongs_to :user, optional: true  # Teacher assigned to supervise
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :start_time, :end_time, presence: true
  validates :venue, presence: true
  validate :end_time_after_start_time
  
  scope :upcoming, -> { where('start_time > ?', Time.current).order(start_time: :asc) }
  scope :ongoing, -> { where('start_time <= ? AND end_time >= ?', Time.current, Time.current) }
  scope :past, -> { where('end_time < ?', Time.current).order(start_time: :desc) }
  scope :by_class, ->(class_id) { where(school_class_id: class_id) }
  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) }
  scope :by_exam_type, ->(exam_type_id) { where(exam_type_id: exam_type_id) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'ExamSchedule').pluck(:resource_id))
  end
  
  def duration
    ((end_time - start_time) / 3600).round(1) if start_time && end_time
  end
  
  def duration_hours
    hours = duration.to_i
    minutes = ((duration - hours) * 60).round
    if minutes > 0
      "#{hours}h #{minutes}m"
    else
      "#{hours}h"
    end
  end
  
  def status
    now = Time.current
    if start_time > now
      'upcoming'
    elsif start_time <= now && end_time >= now
      'ongoing'
    else
      'completed'
    end
  end
  
  def status_color
    case status
    when 'upcoming'
      'bg-blue-100 text-blue-800'
    when 'ongoing'
      'bg-green-100 text-green-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  def formatted_datetime
    "#{start_time.strftime('%b %d, %Y at %I:%M %p')} - #{end_time.strftime('%I:%M %p')}"
  end
  
  def teacher_name
    user&.full_name || 'Not assigned'
  end
  
  private
  
  def end_time_after_start_time
    if end_time && start_time && end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
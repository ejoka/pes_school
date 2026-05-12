class EnterMark < ApplicationRecord
  belongs_to :student
  belongs_to :school_class
  belongs_to :subject
  belongs_to :exam_attendance
  belongs_to :user, optional: true  # Now using user_id instead of entered_by_id
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :marks_obtained, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_marks, presence: true, numericality: { greater_than: 0 }
  validates :marks_obtained, numericality: { less_than_or_equal_to: :total_marks }
  validate :marks_not_exceed_total
  validate :unique_mark_per_exam
  
  before_save :calculate_percentage_and_grade
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'EnterMark').pluck(:resource_id))
  end
  
  def calculate_percentage_and_grade
    if marks_obtained.present? && total_marks.present? && total_marks > 0
      self.percentage = (marks_obtained.to_f / total_marks.to_f * 100).round(2)
      self.grade = determine_grade
    end
  end
  
  def determine_grade
    return nil if percentage.nil?
    
    grade = ExamGrade.find_by('percentage_from <= ? AND percentage_to >= ?', percentage, percentage)
    grade&.name || 'Not Graded'
  end
  
  def grade_color
    case grade
    when 'A', 'A+'
      'bg-green-100 text-green-800'
    when 'B', 'B+'
      'bg-blue-100 text-blue-800'
    when 'C', 'C+'
      'bg-yellow-100 text-yellow-800'
    when 'D', 'D+'
      'bg-orange-100 text-orange-800'
    when 'F'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  def status
    if percentage && exam_attendance&.exam_schedule&.exam_type
      if percentage >= exam_attendance.exam_schedule.exam_type.average_pass_mark
        'pass'
      else
        'fail'
      end
    else
      'pending'
    end
  end
  
  def status_color
    case status
    when 'pass'
      'bg-green-100 text-green-800'
    when 'fail'
      'bg-red-100 text-red-800'
    else
      'bg-yellow-100 text-yellow-800'
    end
  end
  
  private
  
  def marks_not_exceed_total
    if marks_obtained.present? && total_marks.present? && marks_obtained > total_marks
      errors.add(:marks_obtained, "cannot be greater than total marks")
    end
  end
  
  def unique_mark_per_exam
    if exam_attendance_id.present? && student_id.present?
      existing = EnterMark.where(
        exam_attendance_id: exam_attendance_id,
        student_id: student_id
      ).where.not(id: id).exists?
      
      if existing
        errors.add(:base, "Marks have already been entered for this student in this exam")
      end
    end
  end
end
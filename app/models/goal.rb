class Goal < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: 'created_by_id', optional: true
  has_many :tasks, dependent: :destroy
  has_many :goal_progresses, dependent: :destroy
  has_many :notifications, as: :actionable, dependent: :destroy
  
  validates :title, presence: true
  validates :start_date, :end_date, presence: true
  validates :priority, presence: true, inclusion: { in: %w[high medium low] }
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  
  STATUSES = {
    'not_started' => 'Not Started',
    'in_progress' => 'In Progress',
    'completed' => 'Completed',
    'on_hold' => 'On Hold',
    'cancelled' => 'Cancelled'
  }.freeze
  
  PRIORITIES = {
    'high' => 'High',
    'medium' => 'Medium',
    'low' => 'Low'
  }.freeze
  
  scope :active, -> { where.not(status: ['completed', 'cancelled']) }
  scope :by_professional_type, ->(type) { where(professional_type: type) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  
  def update_progress_from_tasks
    if tasks.any?
      completed_tasks = tasks.where(status: 'completed').count
      self.progress = (completed_tasks.to_f / tasks.count * 100).round
      self.status = 'completed' if progress == 100
      self.status = 'in_progress' if progress > 0 && progress < 100
      save
    end
  end
  
  def priority_color
    case priority
    when 'high'
      'bg-red-100 text-red-800'
    when 'medium'
      'bg-yellow-100 text-yellow-800'
    else
      'bg-green-100 text-green-800'
    end
  end
  
  def status_color
    case status
    when 'completed'
      'bg-green-100 text-green-800'
    when 'in_progress'
      'bg-blue-100 text-blue-800'
    when 'on_hold'
      'bg-yellow-100 text-yellow-800'
    when 'cancelled'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  def days_remaining
    return 0 if end_date < Date.today
    (end_date - Date.today).to_i
  end
  
  def is_overdue?
    end_date < Date.today && status != 'completed'
  end
  
  def created_by_name
    user&.full_name || 'System'
  end
end
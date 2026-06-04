class Task < ApplicationRecord
  belongs_to :goal
  belongs_to :user, class_name: 'User', foreign_key: 'assigned_to_id', optional: true
  has_many :notifications, as: :actionable, dependent: :destroy
  
  validates :title, presence: true
  validates :due_date, presence: true
  
  STATUSES = {
    'pending' => 'Pending',
    'in_progress' => 'In Progress',
    'completed' => 'Completed',
    'overdue' => 'Overdue'
  }.freeze
  
  PRIORITIES = {
    'high' => 'High',
    'medium' => 'Medium',
    'low' => 'Low'
  }.freeze
  
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :overdue, -> { where('due_date < ? AND status != ?', Date.today, 'completed') }
  scope :assigned_to_user, ->(user_id) { where(assigned_to_id: user_id) }
  
  before_save :update_status_based_on_due_date
  after_save :update_goal_progress
  after_create :create_notification_for_assignment
  
  def update_status_based_on_due_date
    if status == 'pending' && due_date < Date.today
      self.status = 'overdue'
    end
  end
  
  def update_goal_progress
    goal.update_progress_from_tasks
  end
  
  def create_notification_for_assignment
    if assigned_to_id.present?
      Notification.create(
        user_id: assigned_to_id,
        title: "New Task Assigned",
        message: "You have been assigned a new task: #{title}",
        actionable: self,
        read: false
      )
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
    when 'overdue'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  def assigned_to_name
    user&.full_name || 'Not Assigned'
  end
end
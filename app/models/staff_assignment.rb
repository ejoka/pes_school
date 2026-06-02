class StaffAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :department
  
  has_many :payrolls, dependent: :destroy
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :user_id, uniqueness: { scope: :department_id, message: "already assigned to this department" }
  validates :position, presence: true
  validates :joined_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive on_leave terminated] }
  
  STATUSES = {
    'active' => 'Active',
    'inactive' => 'Inactive',
    'on_leave' => 'On Leave',
    'terminated' => 'Terminated'
  }.freeze
  
  scope :active, -> { where(status: 'active') }
  scope :by_department, ->(dept_id) { where(department_id: dept_id) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'StaffAssignment').pluck(:resource_id))
  end
  
  def status_color
    case status
    when 'active'
      'bg-green-100 text-green-800'
    when 'inactive'
      'bg-gray-100 text-gray-800'
    when 'on_leave'
      'bg-yellow-100 text-yellow-800'
    else
      'bg-red-100 text-red-800'
    end
  end
  
  def total_earned
    payrolls.sum(:net_salary)
  end
end
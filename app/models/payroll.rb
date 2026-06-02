class Payroll < ApplicationRecord
  belongs_to :staff_assignment
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :year, presence: true
  validates :basic_salary, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :allowances, numericality: { greater_than_or_equal_to: 0 }
  validates :deductions, numericality: { greater_than_or_equal_to: 0 }
  validates :staff_assignment_id, uniqueness: { scope: [:month, :year], message: "payroll already exists for this month" }
  validates :status, presence: true, inclusion: { in: %w[draft paid cancelled] }
  
  STATUSES = {
    'draft' => 'Draft',
    'paid' => 'Paid',
    'cancelled' => 'Cancelled'
  }.freeze
  
  before_save :calculate_net_salary
  
  MONTHS = {
    1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April',
    5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August',
    9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'
  }.freeze
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'Payroll').pluck(:resource_id))
  end
  
  def calculate_net_salary
    self.net_salary = basic_salary + allowances - deductions
  end
  
  def month_name
    MONTHS[month]
  end
  
  def status_color
    case status
    when 'paid'
      'bg-green-100 text-green-800'
    when 'cancelled'
      'bg-red-100 text-red-800'
    else
      'bg-yellow-100 text-yellow-800'
    end
  end
end
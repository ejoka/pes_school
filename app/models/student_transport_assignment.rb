class StudentTransportAssignment < ApplicationRecord
  belongs_to :student
  belongs_to :route
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :student_id, presence: true, uniqueness: { scope: :route_id, message: "is already assigned to a transport route" }
  validates :route_id, presence: true
  validates :assigned_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }
  
  STATUSES = {
    'active' => 'Active',
    'inactive' => 'Inactive'
  }.freeze
  
  scope :active, -> { where(status: 'active') }
  scope :by_route, ->(route_id) { where(route_id: route_id) }
  scope :by_student, ->(student_id) { where(student_id: student_id) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'StudentTransportAssignment').pluck(:resource_id))
  end
  
  def status_color
    case status
    when 'active'
      'bg-green-100 text-green-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  def status_badge
    STATUSES[status] || status.humanize
  end
  
  def student_name
    student&.full_name
  end
  
  def route_info
    "#{route&.name} - #{route&.formatted_fare}" if route
  end
  
  def has_paid_transport_fee?
    # Check if student has paid transport fee
    # This checks for 'Transport Fee' in student_fees
    student.student_fees.joins(:fee_category)
           .where(fee_categories: { name: 'Transport Fee' })
           .where('student_fees.amount_paid >= student_fees.amount')
           .exists?
  end
  
  def transport_fee_status
    if has_paid_transport_fee?
      'Paid'
    else
      'Unpaid'
    end
  end
  
  def transport_fee_color
    if has_paid_transport_fee?
      'bg-green-100 text-green-800'
    else
      'bg-red-100 text-red-800'
    end
  end
end
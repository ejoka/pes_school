class StaffLeaveRequest < ApplicationRecord
  belongs_to :staff_assignment
  belongs_to :user, optional: true 
  
  validates :leave_type, presence: true, inclusion: { in: %w[annual sick emergency unpaid other] }
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  
  LEAVE_TYPES = {
    'annual' => 'Annual Leave',
    'sick' => 'Sick Leave',
    'emergency' => 'Emergency Leave',
    'unpaid' => 'Unpaid Leave',
    'other' => 'Other'
  }.freeze
  
  STATUSES = {
    'pending' => 'Pending',
    'approved' => 'Approved',
    'rejected' => 'Rejected',
    'cancelled' => 'Cancelled'
  }.freeze
  
  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :for_period, ->(start_date, end_date) { where('start_date <= ? AND end_date >= ?', end_date, start_date) }
  
  def leave_days
    ((end_date - start_date).to_i + 1).days
  end
  
  def status_color
    case status
    when 'approved'
      'bg-green-100 text-green-800'
    when 'rejected'
      'bg-red-100 text-red-800'
    when 'cancelled'
      'bg-gray-100 text-gray-800'
    else
      'bg-yellow-100 text-yellow-800'
    end
  end
  
  def leave_type_humanized
    LEAVE_TYPES[leave_type] || leave_type.humanize
  end
  
  def approver_name
    user&.full_name || 'Not approved yet'
  end

  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'StaffLeaveRequest').pluck(:resource_id))
  end
  
  private
  
  def end_date_after_start_date
    if end_date && start_date && end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
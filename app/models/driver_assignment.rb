class DriverAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :school_bus
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :user_id, presence: true, uniqueness: { scope: :school_bus_id, message: "is already assigned to this bus" }
  validates :school_bus_id, presence: true
  validates :id_type, presence: true, inclusion: { in: %w[national_id drivers_licence passport] }
  validates :id_number, presence: true
  validates :assigned_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive suspended] }
  
  ID_TYPES = {
    'national_id' => 'National ID',
    'drivers_licence' => "Driver's Licence",
    'passport' => 'Passport'
  }.freeze
  
  STATUSES = {
    'active' => 'Active',
    'inactive' => 'Inactive',
    'suspended' => 'Suspended'
  }.freeze
  
  scope :active, -> { where(status: 'active') }
  scope :by_bus, ->(bus_id) { where(school_bus_id: bus_id) }
  scope :by_driver, ->(driver_id) { where(user_id: driver_id) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'DriverAssignment').pluck(:resource_id))
  end
  
  def id_type_humanized
    ID_TYPES[id_type] || id_type.humanize
  end
  
  def status_color
    case status
    when 'active'
      'bg-green-100 text-green-800'
    when 'inactive'
      'bg-gray-100 text-gray-800'
    else
      'bg-red-100 text-red-800'
    end
  end
  
  def status_badge
    STATUSES[status] || status.humanize
  end
  
  def driver_name
    user&.full_name || 'Not assigned'
  end
  
  def bus_info
    "#{school_bus&.bus_number} - #{school_bus&.bus_model}" if school_bus
  end
end
class BusRouteAssignment < ApplicationRecord
  belongs_to :school_bus
  belongs_to :route
  
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :school_bus_id, presence: true, uniqueness: { scope: :route_id, message: "is already assigned to this route" }
  validates :route_id, presence: true
  validates :assigned_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }
  
  STATUSES = {
    'active' => 'Active',
    'inactive' => 'Inactive'
  }.freeze
  
  scope :active, -> { where(status: 'active') }
  scope :by_bus, ->(bus_id) { where(school_bus_id: bus_id) }
  scope :by_route, ->(route_id) { where(route_id: route_id) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'BusRouteAssignment').pluck(:resource_id))
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
  
  def bus_info
    "#{school_bus&.bus_number} - #{school_bus&.bus_model} (Capacity: #{school_bus&.capacity})" if school_bus
  end
  
  def route_info
    "#{route&.name} - #{route&.formatted_fare}" if route
  end
end
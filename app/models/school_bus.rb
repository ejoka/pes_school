class SchoolBus < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :bus_number, presence: true, uniqueness: true
  validates :bus_model, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :status, presence: true, inclusion: { in: %w[active maintenance retired] }
  
  scope :active, -> { where(status: 'active') }
  scope :ordered, -> { order(:bus_number) }
  
  STATUSES = {
    'active' => 'Active',
    'maintenance' => 'Under Maintenance',
    'retired' => 'Retired'
  }.freeze
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'SchoolBus').pluck(:resource_id))
  end
  
  def status_color
    case status
    when 'active'
      'bg-green-100 text-green-800'
    when 'maintenance'
      'bg-yellow-100 text-yellow-800'
    else
      'bg-red-100 text-red-800'
    end
  end
  
  def status_badge
    STATUSES[status] || status.humanize
  end
end
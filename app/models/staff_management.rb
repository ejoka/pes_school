class StaffManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Staff Management') do |sm|
      sm.description = 'Manage departments, staff assignments, and payroll.'
    end
  end
end
class GoalManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Goal Management') do |gm|
      gm.description = 'Manage goals, tasks, and track progress.'
    end
  end
end
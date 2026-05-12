class ExamType < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: true
  validates :average_pass_mark, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  
  scope :ordered, -> { order(:name) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'ExamType').pluck(:resource_id))
  end
  
  def pass_mark_status
    if average_pass_mark >= 75
      'High'
    elsif average_pass_mark >= 50
      'Medium'
    else
      'Low'
    end
  end
  
  def status_color
    case pass_mark_status
    when 'High'
      'bg-green-100 text-green-800'
    when 'Medium'
      'bg-yellow-100 text-yellow-800'
    else
      'bg-red-100 text-red-800'
    end
  end
end
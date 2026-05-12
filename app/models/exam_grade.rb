class ExamGrade < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: true
  validates :percentage_from, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :percentage_to, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :percentage_range_valid
  
  default_scope { order(percentage_to: :desc, percentage_from: :desc) }
  scope :ordered, -> { order(percentage_to: :desc, percentage_from: :desc) }
  
  def percentage_range
    "#{percentage_from}% - #{percentage_to}%"
  end
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'ExamGrade').pluck(:resource_id))
  end
  
  private
  
  def percentage_range_valid
    if percentage_from.present? && percentage_to.present?
      if percentage_from >= percentage_to
        errors.add(:percentage_to, "must be greater than percentage from")
      end
      if percentage_from < 0 || percentage_from > 100
        errors.add(:percentage_from, "must be between 0 and 100")
      end
      if percentage_to < 0 || percentage_to > 100
        errors.add(:percentage_to, "must be between 0 and 100")
      end
    end
  end
end
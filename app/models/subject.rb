class Subject < ApplicationRecord
  validates :name, :subject_code, presence: true
  validates :subject_code, uniqueness: true
  validates :pass_mark, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  belongs_to :school_class
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'Subject').pluck(:resource_id))
  end
end
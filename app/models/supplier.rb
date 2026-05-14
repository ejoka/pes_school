class Supplier < ApplicationRecord
  has_many :inventory_items, dependent: :restrict_with_error
  has_many :stock_receipts, dependent: :restrict_with_error
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: true
  validates :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  
  scope :ordered, -> { order(:name) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'Supplier').pluck(:resource_id))
  end
  
  def contact_info
    "#{contact_person} - #{phone}"
  end
end
class InventoryItem < ApplicationRecord
  belongs_to :inventory_category
  belongs_to :supplier, optional: true
  has_many :stock_movements, dependent: :destroy
  has_many :stock_receipt_items, dependent: :destroy
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources
  
  validates :name, presence: true, uniqueness: { scope: :inventory_category_id }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  
  scope :low_stock, -> { where('quantity <= minimum_stock') }
  scope :out_of_stock, -> { where(quantity: 0) }
  scope :in_stock, -> { where('quantity > 0') }
  scope :by_category, ->(category_id) { where(inventory_category_id: category_id) }
  
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'InventoryItem').pluck(:resource_id))
  end
  
  def used_quantity
    stock_movements.where(movement_type: 'issue').sum(:quantity)
  end
  
  def remaining_quantity
    quantity - used_quantity
  end
  
  def needs_reorder?
    remaining_quantity <= minimum_stock
  end
  
  def stock_status
    if remaining_quantity <= 0
      { text: 'Out of Stock', color: 'bg-red-100 text-red-800' }
    elsif remaining_quantity <= minimum_stock
      { text: 'Low Stock', color: 'bg-yellow-100 text-yellow-800' }
    else
      { text: 'In Stock', color: 'bg-green-100 text-green-800' }
    end
  end
  
  def total_value
    quantity * (unit_price || 0)
  end
end
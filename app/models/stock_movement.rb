class StockMovement < ApplicationRecord
  belongs_to :inventory_item
  belongs_to :user, optional: true
  
  validates :movement_type, presence: true, inclusion: { in: %w[receive issue adjust] }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  
  scope :receipts, -> { where(movement_type: 'receive') }
  scope :issues, -> { where(movement_type: 'issue') }
  scope :adjustments, -> { where(movement_type: 'adjust') }
  
  after_create :update_inventory_quantity
  
  def update_inventory_quantity
    if movement_type == 'receive'
      inventory_item.update(quantity: inventory_item.quantity + quantity)
    elsif movement_type == 'issue'
      inventory_item.update(quantity: inventory_item.quantity - quantity)
    end
  end
end
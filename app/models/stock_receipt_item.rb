class StockReceiptItem < ApplicationRecord
  belongs_to :stock_receipt
  belongs_to :inventory_item
  
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_save :calculate_total_price
  
  def calculate_total_price
    self.total_price = quantity * unit_price
  end
end
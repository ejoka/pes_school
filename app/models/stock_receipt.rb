class StockReceipt < ApplicationRecord
  belongs_to :supplier
  belongs_to :user, class_name: 'User', optional: true
  has_many :stock_receipt_items, dependent: :destroy
  has_many :inventory_items, through: :stock_receipt_items
  
  validates :receipt_number, presence: true, uniqueness: true
  validates :received_date, presence: true
  
  STATUSES = {
    'pending' => 'Pending',
    'received' => 'Received',
    'cancelled' => 'Cancelled'
  }.freeze
  
  scope :pending, -> { where(status: 'pending') }
  scope :received, -> { where(status: 'received') }
  
  before_validation :generate_receipt_number, on: :create
  
  def total_amount
    stock_receipt_items.sum(:total_price)
  end
  
  def status_color
    case status
    when 'received'
      'bg-green-100 text-green-800'
    when 'cancelled'
      'bg-red-100 text-red-800'
    else
      'bg-yellow-100 text-yellow-800'
    end
  end
  
  def performed_by_name
    user&.full_name || 'System'
  end
  
  private
  
  def generate_receipt_number
    return if receipt_number.present?
    year = Time.now.strftime('%Y')
    month = Time.now.strftime('%m')
    count = StockReceipt.where("receipt_number LIKE ?", "PO-#{year}#{month}-%").count + 1
    self.receipt_number = "PO-#{year}#{month}-#{count.to_s.rjust(4, '0')}"
  end
end
class Fee < ApplicationRecord
  belongs_to :student
  belongs_to :fee_type
  
  has_many :payments, dependent: :destroy
  
  validates :amount_to_pay, presence: true, numericality: { greater_than: 0 }
  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  
  before_validation :calculate_remaining_balance
  before_save :update_status
  
  STATUSES = {
    'unpaid' => 'Unpaid',
    'partially_paid' => 'Partially Paid',
    'fully_paid' => 'Fully Paid',
    'overdue' => 'Overdue'
  }.freeze
  
  def calculate_remaining_balance
    self.remaining_balance = amount_to_pay - amount_paid
  end
  
  def update_status
    if amount_paid >= amount_to_pay
      self.status = 'fully_paid'
    elsif amount_paid > 0
      self.status = 'partially_paid'
      # Check if overdue
      if due_date && due_date < Date.today
        self.status = 'overdue'
      end
    else
      self.status = due_date && due_date < Date.today ? 'overdue' : 'unpaid'
    end
  end
  
  def percentage_paid
    return 0 if amount_to_pay == 0
    (amount_paid / amount_to_pay * 100).round(2)
  end
  
  def status_color
    case status
    when 'fully_paid'
      'bg-green-100 text-green-800'
    when 'partially_paid'
      'bg-yellow-100 text-yellow-800'
    when 'overdue'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
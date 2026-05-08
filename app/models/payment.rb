class Payment < ApplicationRecord
  belongs_to :student
  belongs_to :fee
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
  validates :payment_method, presence: true
  
  after_create :update_fee_payment
  
  PAYMENT_METHODS = [
    'Cash',
    'Bank Transfer',
    'Check',
    'Credit Card',
    'Mobile Money',
    'Online Payment'
  ].freeze
  
  private
  
  def update_fee_payment
    fee.update(amount_paid: fee.amount_paid + amount)
  end
end
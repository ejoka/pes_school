class Payment < ApplicationRecord
  belongs_to :student
  belongs_to :payable, polymorphic: true, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
  validates :payment_method, presence: true
  
  PAYMENT_METHODS = ['Cash', 'Bank Transfer', 'Check', 'Credit Card', 'Mobile Money', 'Online Payment'].freeze
  
  # Remove the after_create callbacks that might cause recursion
  after_create :update_associated_fee
  after_destroy :update_associated_fee
  
  def update_associated_fee
    return unless payable_type == 'StudentFee' && payable_id.present?
    
    # Find the fee and update its status without triggering additional callbacks
    fee = StudentFee.find_by(id: payable_id)
    if fee
      fee.update_column(:is_paid, fee.payments.sum(:amount) >= fee.amount)
    end
  end
end
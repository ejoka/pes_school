class Payment < ApplicationRecord
  belongs_to :student
  belongs_to :payable, polymorphic: true, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
  validates :payment_method, presence: true
  
  PAYMENT_METHODS = ['Cash', 'Bank Transfer', 'Check', 'Credit Card', 'Mobile Money', 'Online Payment'].freeze
  
  after_create :update_associated_fee
  after_create :update_student_balance
  
  def update_associated_fee
    if payable_type == 'StudentFee'
      payable&.update_payment_status
    end
  end
  
  def update_student_balance
    student.update_total_balance
  end
end
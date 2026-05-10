class StudentFee < ApplicationRecord
  belongs_to :student
  belongs_to :fee_category
  belongs_to :invoice, optional: true
  
  has_many :payments, as: :payable, dependent: :destroy
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  
  scope :paid, -> { where(is_paid: true) }
  scope :unpaid, -> { where(is_paid: false) }
  scope :overdue, -> { where('due_date < ? AND is_paid = ?', Date.today, false) }
  
  # Remove before_save callback that might cause recursion
  # Use after_save instead with update_column to avoid recursion
  after_save :update_payment_status, if: :saved_change_to_amount?
  after_save :update_invoice_totals, if: :saved_change_to_amount?
  
  def update_payment_status
    total_paid = payments.sum(:amount)
    new_status = total_paid >= amount
    update_column(:is_paid, new_status) if is_paid != new_status
  end
  
  def update_invoice_totals
    return unless invoice_id.present?
    
    # Update invoice totals without triggering callbacks
    invoice = Invoice.find_by(id: invoice_id)
    if invoice
      total_amount = invoice.student_fees.sum(:amount)
      total_paid = invoice.student_fees.sum(:amount_paid)
      invoice.update_columns(
        total_amount: total_amount,
        paid_amount: total_paid
      )
    end
  end
  
  def amount_paid
    payments.sum(:amount)
  end
  
  def remaining_balance
    amount - amount_paid
  end
  
  def percentage_paid
    return 0 if amount == 0
    (amount_paid / amount * 100).round(2)
  end
  
  def status
    if is_paid
      'paid'
    elsif due_date < Date.today
      'overdue'
    elsif amount_paid > 0
      'partial'
    else
      'unpaid'
    end
  end
  
  def status_color
    case status
    when 'paid'
      'bg-green-100 text-green-800'
    when 'partial'
      'bg-yellow-100 text-yellow-800'
    when 'overdue'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
class Invoice < ApplicationRecord
  belongs_to :student
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true
  has_many :student_fees, dependent: :nullify
  has_many :payments, as: :payable
  
  validates :invoice_number, presence: true, uniqueness: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  
  before_validation :generate_invoice_number, on: :create
  before_save :update_status
  
  STATUSES = {
    'draft' => 'Draft',
    'sent' => 'Sent',
    'paid' => 'Paid',
    'partially_paid' => 'Partially Paid',
    'overdue' => 'Overdue',
    'cancelled' => 'Cancelled'
  }.freeze
  
  def update_status
    if paid_amount.to_f >= total_amount.to_f
      self.status = 'paid'
    elsif paid_amount.to_f > 0
      self.status = 'partially_paid'
    elsif due_date.present? && due_date < Date.today
      self.status = 'overdue'
    else
      self.status = 'sent' if status.blank? || status == 'draft'
    end
    true
  end
  
  def update_totals_from_fees
    # Direct SQL update to avoid callback issues
    new_total = student_fees.sum(:amount).to_f
    new_paid = student_fees.joins(:payments).sum('payments.amount').to_f
    
    # Update using SQL directly
    self.class.where(id: id).update_all(
      total_amount: new_total,
      paid_amount: new_paid
    )
    
    # Reload the record to get updated values
    reload
    
    # Update status
    update_status
    save
    
    new_total
  end
  
  def remaining_balance
    (total_amount.to_f - paid_amount.to_f).round(2)
  end
  
  def percentage_paid
    return 0 if total_amount.to_f == 0
    ((paid_amount.to_f / total_amount.to_f) * 100).round(2)
  end
  
  def status_color
    case status
    when 'paid'
      'bg-green-100 text-green-800'
    when 'partially_paid'
      'bg-yellow-100 text-yellow-800'
    when 'overdue'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
  
  def refresh!
    update_totals_from_fees
  end
  
  private
  
  def generate_invoice_number
    return if invoice_number.present?
    year = Time.now.strftime('%Y')
    month = Time.now.strftime('%m')
    count = Invoice.where("invoice_number LIKE ?", "INV-#{year}#{month}-%").count + 1
    self.invoice_number = "INV-#{year}#{month}-#{count.to_s.rjust(4, '0')}"
  end
end
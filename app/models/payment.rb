class Payment < ApplicationRecord
  belongs_to :student
  belongs_to :payable, polymorphic: true, optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
  validates :payment_method, presence: true
  
  PAYMENT_METHODS = ['Cash', 'Bank Transfer', 'Check', 'Credit Card', 'Mobile Money', 'Online Payment'].freeze
  
  after_create :sync_related_records
  after_destroy :sync_related_records
  
  def sync_related_records
    # Update the fee's paid status
    if payable_type == 'StudentFee' && payable_id.present?
      fee = StudentFee.find_by(id: payable_id)
      if fee
        fee.update_payment_status
        # Sync the invoice if fee belongs to one
        if fee.invoice_id.present?
          invoice = Invoice.find_by(id: fee.invoice_id)
          invoice.update_totals_from_fees if invoice
        end
      end
    end
  end
  
  def update_associated_fee
    # Legacy method - kept for compatibility
    sync_related_records
  end
end
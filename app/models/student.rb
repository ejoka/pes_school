class Student < ApplicationRecord
  belongs_to :school_class
  belongs_to :user, optional: true
  has_one :parent_info, dependent: :destroy
  has_many :student_fees, dependent: :destroy  # Changed from has_one :student_fee
  has_many :fee_categories, through: :student_fees
  has_many :payments, dependent: :destroy
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  # Validations
  validates :first_name, :last_name, :date_of_birth, :gender, :academic_year, :admission_date, presence: true
  validates :gender, inclusion: { in: %w[Male Female Other] }
  validates :religion, presence: true, allow_blank: true

  # Callbacks
  after_initialize :set_defaults, if: :new_record?
  after_create :create_parent_info

  def full_name
    [first_name, middle_name, last_name].compact.join(' ')
  end

  def age
    return nil unless date_of_birth
    now = Time.now.utc.to_date
    now.year - date_of_birth.year - (date_of_birth.to_date.change(year: now.year) > now ? 1 : 0)
  end
  
  # Fee management methods
  def total_fees_due
    student_fees.sum(:amount)
  end
  
  def total_paid
    payments.sum(:amount)
  end
  
  def current_balance
    total_fees_due - total_paid
  end
  
  def update_total_balance
    # This will be called after payments
    # Update any cached balance if needed
  end
  
  def generate_invoice
    {
      student: self,
      fees: student_fees.includes(:fee_category).order(:due_date),
      payments: payments.order(payment_date: :desc),
      total_due: total_fees_due,
      total_paid: total_paid,
      balance: current_balance,
      generated_at: Time.current
    }
  end

  # Scope for accessible students based on user permissions
  def self.accessible_by(user)
    return all if user.admin?
    where(id: user.user_resources.where(resource_type: 'Student').pluck(:resource_id))
  end

  private

  def set_defaults
    self.admission_date ||= Date.today
  end

  def create_parent_info
    build_parent_info.save unless parent_info.present?
  end
end
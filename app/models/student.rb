class Student < ApplicationRecord
  belongs_to :school_class
  belongs_to :user, optional: true # The user who created/updated the student record
  has_one :parent_info, dependent: :destroy

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

  private

  def set_defaults
    self.admission_date ||= Date.today
  end

  def create_parent_info
    build_parent_info.save unless parent_info.present?
  end
end
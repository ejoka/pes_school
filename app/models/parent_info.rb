class ParentInfo < ApplicationRecord
  belongs_to :student

  # Validations for phone numbers and emails
  validates :father_phone, :mother_phone, :guardian_phone, format: { with: /\A\+?[\d\s\-\(\)]+\z/, allow_blank: true }
  validates :father_email, :mother_email, :guardian_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  def full_father_name
    father_name.presence || 'Not provided'
  end

  def full_mother_name
    mother_name.presence || 'Not provided'
  end

  def full_guardian_name
    guardian_name.presence || 'Not provided'
  end
end
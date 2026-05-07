class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # Attributes
  validates :first_name, :last_name, :email, presence: true
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]+\z/, allow_blank: true }
  
  # Professional Type
  validates :professional_type, presence: true, if: -> { !admin? }
  
  # Define professional type options
  PROFESSIONAL_TYPES = [
    ['Teacher', 'teacher'],
    ['Administrator', 'administrator'],
    ['Librarian', 'librarian'],
    ['Counselor', 'counselor'],
    ['Principal', 'principal'],
    ['Vice Principal', 'vice_principal'],
    ['Department Head', 'department_head'],
    ['Accountant', 'accountant'],
    ['IT Staff', 'it_staff'],
    ['Security', 'security'],
    ['Maintenance', 'maintenance'],
    ['Other', 'other']
  ].freeze

  # Relationships
  has_many :user_resources, dependent: :destroy
  
  # Polymorphic associations with proper class names
  has_many :assigned_categories, through: :user_resources, source: :resource, source_type: 'Category'
  has_many :assigned_school_classes, through: :user_resources, source: :resource, source_type: 'SchoolClass'
  has_many :assigned_subjects, through: :user_resources, source: :resource, source_type: 'Subject'

  # Role management
  enum :role, { user: 0, admin: 1 }

  # Callbacks
  after_initialize :set_default_role, if: :new_record?
  after_initialize :set_default_professional_type, if: :new_record?

  def full_name
    [title, first_name, middle_name, last_name].compact.join(' ')
  end

  def can_access?(resource, action = :view)
    return true if admin?
    
    user_resource = user_resources.find_by(resource_type: resource.class.name, resource_id: resource.id)
    user_resource&.can?(action) || false
  end

  # Helper method for backward compatibility
  def assigned_classes
    assigned_school_classes
  end

  # Get permissions for a specific resource
  def permissions_for(resource)
    user_resources.find_by(resource_type: resource.class.name, resource_id: resource.id)&.permissions || {}
  end

  def professional_type_humanized
    return 'N/A' if admin?
    PROFESSIONAL_TYPES.find { |type| type[1] == professional_type }&.first || professional_type&.humanize || 'Not specified'
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def set_default_professional_type
    self.professional_type ||= 'teacher' unless admin?
  end
end
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # Attributes
  validates :first_name, :last_name, :email, presence: true
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]+\z/, allow_blank: true }
  
  # Professional Type - allow any string, no predefined list
  validates :professional_type, presence: true, if: -> { !admin? }
  
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
    professional_type.present? ? professional_type.titleize : 'Not specified'
  end

  # Get all unique professional types from existing users (for dropdown options)
  def self.unique_professional_types
    where.not(professional_type: nil).distinct.pluck(:professional_type).sort
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def set_default_professional_type
    self.professional_type ||= 'Teacher' unless admin?
  end
end
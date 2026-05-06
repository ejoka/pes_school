class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # Attributes
  validates :first_name, :last_name, :email, presence: true
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]+\z/, allow_blank: true }

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

  private

  def set_default_role
    self.role ||= :user
  end
end
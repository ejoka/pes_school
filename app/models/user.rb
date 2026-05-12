class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  # Attributes
  validates :first_name, :last_name, :email, presence: true
  validates :phone_number, format: { with: /\A\+?[\d\s\-\(\)]+\z/, allow_blank: true }
  
  # Professional Type
  validates :professional_type, presence: true, if: -> { !admin? }

  # Relationships
  has_many :user_resources, dependent: :destroy
  
  # Polymorphic associations with proper class names
  has_many :assigned_categories, through: :user_resources, source: :resource, source_type: 'Category'
  has_many :assigned_school_classes, through: :user_resources, source: :resource, source_type: 'SchoolClass'
  has_many :assigned_subjects, through: :user_resources, source: :resource, source_type: 'Subject'
  has_many :assigned_student_managements, through: :user_resources, source: :resource, source_type: 'StudentManagement'
  has_many :assigned_fee_managements, through: :user_resources, source: :resource, source_type: 'FeeManagement'
  has_many :assigned_exam_grades, through: :user_resources, source: :resource, source_type: 'ExamGrade'
  has_many :assigned_exam_managements, through: :user_resources, source: :resource, source_type: 'ExamManagement'
  has_many :assigned_exam_types, through: :user_resources, source: :resource, source_type: 'ExamType'
  has_many :assigned_exam_attendances, through: :user_resources, source: :resource, source_type: 'ExamAttendance'
  
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
  
  def can_manage_students?(action = :view)
    return true if admin?
    student_management = StudentManagement.default
    can_access?(student_management, action)
  end

  def can_manage_fees?(action = :view)
    return true if admin?
    fee_management = FeeManagement.default
    can_access?(fee_management, action)
  end

  def can_manage_exams?(action = :view)
    return true if admin?
    exam_management = ExamManagement.default
    can_access?(exam_management, action)
  end

  def can_generate_invoice?
    return true if admin?
    can_manage_fees?(:view) || can_manage_fees?(:edit)
  end
  
  def accessible_students
    if admin?
      Student.all
    elsif can_manage_fees?(:view)
      Student.all
    else
      Student.none
    end
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
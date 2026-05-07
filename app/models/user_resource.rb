class UserResource < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true

  validates :user_id, presence: true
  validates :resource_id, presence: true
  validates :resource_type, presence: true
  validates :user_id, uniqueness: { scope: [:resource_type, :resource_id] }
  validates :resource_type, inclusion: { in: %w[Category SchoolClass Subject StudentManagement] }

  # Store permissions as JSON
  store :permissions, accessors: [:can_view, :can_create, :can_edit, :can_delete], coder: JSON

  after_initialize :set_default_permissions

  def set_default_permissions
    self.permissions ||= {
      'can_view' => true,
      'can_create' => false,
      'can_edit' => false,
      'can_delete' => false
    }
  end

  def can?(action)
    case action.to_s
    when 'view', 'read'
      can_view
    when 'create', 'new'
      can_create
    when 'edit', 'update'
      can_edit
    when 'delete', 'destroy'
      can_delete
    else
      false
    end
  end
end
class UserResource < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true

  validates :user_id, presence: true
  validates :resource_id, presence: true
  validates :resource_type, presence: true
  validates :user_id, uniqueness: { scope: [:resource_type, :resource_id] }

  # Optional: Add validation to ensure resource_type is one of the allowed models
  validates :resource_type, inclusion: { in: %w[Category SchoolClass Subject] }
end
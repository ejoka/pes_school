class UserResource < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true

  validates :user_id, uniqueness: { scope: [:resource_type, :resource_id] }
end
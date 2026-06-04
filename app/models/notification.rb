class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actionable, polymorphic: true, optional: true
  
  validates :title, :message, presence: true
  
  scope :unread, -> { where(read: false) }
  scope :read, -> { where(read: true) }
  scope :recent, -> { order(created_at: :desc).limit(10) }
  
  def mark_as_read!
    update(read: true)
  end
  
  def self.mark_all_as_read(user)
    where(user: user, read: false).update_all(read: true)
  end
end
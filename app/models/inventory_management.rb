class InventoryManagement < ApplicationRecord
  has_many :user_resources, as: :resource, dependent: :destroy
  has_many :users, through: :user_resources

  validates :name, presence: true, uniqueness: true

  def self.default
    find_or_create_by(name: 'Inventory Management') do |im|
      im.description = 'Manage inventory items, suppliers, stock movements, and receipts.'
    end
  end
end
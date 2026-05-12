class Setting < ApplicationRecord
  has_one_attached :logo
  
  validates :key, presence: true, uniqueness: true
  
  def self.get(key, default = nil)
    setting = find_by(key: key)
    setting ? setting.value : default
  end
  
  def self.set(key, value)
    setting = find_or_create_by(key: key)
    setting.update(value: value)
  end
  
  def self.logo_url
    setting = find_by(key: 'logo')
    setting&.logo&.attached? ? setting.logo : nil
  end
end
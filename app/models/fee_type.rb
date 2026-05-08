class FeeType < ApplicationRecord
  has_many :fees, dependent: :restrict_with_error
  
  validates :name, presence: true, uniqueness: true
  
  FEE_TYPES = [
    'Tuition Fee',
    'Meals',
    'Transport Fee',
    'Graduation Fee',
    'Stationary',
    'Uniform Fee',
    'School Development Fee',
    'Miscellaneous'
  ].freeze
  
  def self.seed_fee_types
    FEE_TYPES.each do |fee_name|
      find_or_create_by(name: fee_name) do |fee_type|
        fee_type.description = "#{fee_name} charges for students"
      end
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["name", "description", "created_at", "updated_at"]
  end
end
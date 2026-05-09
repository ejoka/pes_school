class FeeCategory < ApplicationRecord
  has_many :student_fees, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  
  FEE_CATEGORIES = [
    { name: 'Tuition Fee', is_recurring: true },
    { name: 'Meals', is_recurring: true },
    { name: 'Transport Fee', is_recurring: true },
    { name: 'Graduation Fee', is_recurring: false },
    { name: 'Stationary', is_recurring: false },
    { name: 'Uniform Fee', is_recurring: false },
    { name: 'School Development Fee', is_recurring: false },
    { name: 'Miscellaneous', is_recurring: false }
  ].freeze
  
  def self.seed_categories
    FEE_CATEGORIES.each do |category|
      find_or_create_by(name: category[:name]) do |cat|
        cat.is_recurring = category[:is_recurring]
        cat.description = "#{category[:name]} charges for students"
      end
    end
  end
end
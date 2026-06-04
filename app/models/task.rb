class Task < ApplicationRecord
  belongs_to :goal
  belongs_to :assigned_to
end

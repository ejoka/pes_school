class BusRouteAssignment < ApplicationRecord
  belongs_to :school_bus
  belongs_to :route
end

module Admin
  class BusRouteAssignmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_transport_permission!
    before_action :set_bus_route_assignment, only: [:show, :edit, :update, :destroy]

    def index
      @bus_route_assignments = if current_user.admin?
                                  BusRouteAssignment.includes(:school_bus, :route).order(created_at: :desc)
                                else
                                  BusRouteAssignment.accessible_by(current_user).includes(:school_bus, :route).order(created_at: :desc)
                                end
      
      # Statistics
      @total_assignments = @bus_route_assignments.count
      @active_assignments = @bus_route_assignments.active.count
      @inactive_assignments = @bus_route_assignments.where(status: 'inactive').count
    end

    def show
    end

    def new
      @bus_route_assignment = BusRouteAssignment.new
      @school_buses = SchoolBus.active.order(:bus_number)
      @routes = Route.ordered.all
    end

    def create
      @bus_route_assignment = BusRouteAssignment.new(bus_route_assignment_params)
      
      if @bus_route_assignment.save
        redirect_to admin_bus_route_assignments_path, notice: 'Bus was successfully assigned to route.'
      else
        @school_buses = SchoolBus.active.order(:bus_number)
        @routes = Route.ordered.all
        render :new
      end
    end

    def edit
      @school_buses = SchoolBus.active.order(:bus_number)
      @routes = Route.ordered.all
    end

    def update
      if @bus_route_assignment.update(bus_route_assignment_params)
        redirect_to admin_bus_route_assignments_path, notice: 'Bus route assignment was successfully updated.'
      else
        @school_buses = SchoolBus.active.order(:bus_number)
        @routes = Route.ordered.all
        render :edit
      end
    end

    def destroy
      @bus_route_assignment.destroy
      redirect_to admin_bus_route_assignments_path, notice: 'Bus route assignment was successfully removed.'
    end

    private

    def ensure_transport_permission!
      unless current_user.admin? || current_user.can_manage_transport?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access bus route assignments.'
      end
    end

    def set_bus_route_assignment
      @bus_route_assignment = BusRouteAssignment.find(params[:id])
    end

    def bus_route_assignment_params
      params.require(:bus_route_assignment).permit(:school_bus_id, :route_id, :description, :assigned_date, :status)
    end
  end
end
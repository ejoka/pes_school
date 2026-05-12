module Admin
  class DriverAssignmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_transport_permission!
    before_action :set_driver_assignment, only: [:show, :edit, :update, :destroy]

    def index
      @driver_assignments = if current_user.admin?
                              DriverAssignment.includes(:user, :school_bus).order(created_at: :desc)
                            else
                              DriverAssignment.accessible_by(current_user).includes(:user, :school_bus).order(created_at: :desc)
                            end
      
      # Statistics
      @total_assignments = @driver_assignments.count
      @active_assignments = @driver_assignments.active.count
      @inactive_assignments = @driver_assignments.where(status: 'inactive').count
      @suspended_assignments = @driver_assignments.where(status: 'suspended').count
    end

    def show
    end

    def new
      @driver_assignment = DriverAssignment.new
      @drivers = User.where(professional_type: 'driver').or(User.where(role: :admin)).order(:first_name)
      @school_buses = SchoolBus.active.order(:bus_number)
    end

    def create
      @driver_assignment = DriverAssignment.new(driver_assignment_params)
      
      if @driver_assignment.save
        redirect_to admin_driver_assignments_path, notice: 'Driver was successfully assigned.'
      else
        @drivers = User.where(professional_type: 'driver').or(User.where(role: :admin)).order(:first_name)
        @school_buses = SchoolBus.active.order(:bus_number)
        render :new
      end
    end

    def edit
      @drivers = User.where(professional_type: 'driver').or(User.where(role: :admin)).order(:first_name)
      @school_buses = SchoolBus.active.order(:bus_number)
    end

    def update
      if @driver_assignment.update(driver_assignment_params)
        redirect_to admin_driver_assignments_path, notice: 'Driver assignment was successfully updated.'
      else
        @drivers = User.where(professional_type: 'driver').or(User.where(role: :admin)).order(:first_name)
        @school_buses = SchoolBus.active.order(:bus_number)
        render :edit
      end
    end

    def destroy
      @driver_assignment.destroy
      redirect_to admin_driver_assignments_path, notice: 'Driver assignment was successfully removed.'
    end

    private

    def ensure_transport_permission!
      unless current_user.admin? || current_user.can_manage_transport?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access driver assignments.'
      end
    end

    def set_driver_assignment
      @driver_assignment = DriverAssignment.find(params[:id])
    end

    def driver_assignment_params
      params.require(:driver_assignment).permit(:user_id, :school_bus_id, :id_type, :id_number, :description, :assigned_date, :status)
    end
  end
end
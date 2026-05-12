module Admin
  class SchoolBusesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_transport_permission!
    before_action :set_school_bus, only: [:show, :edit, :update, :destroy]

    def index
      @school_buses = if current_user.admin?
                        SchoolBus.ordered.all
                      else
                        SchoolBus.accessible_by(current_user).ordered
                      end
    end

    def show
    end

    def new
      @school_bus = SchoolBus.new
    end

    def create
      @school_bus = SchoolBus.new(school_bus_params)
      
      if @school_bus.save
        redirect_to admin_school_buses_path, notice: 'School bus was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @school_bus.update(school_bus_params)
        redirect_to admin_school_buses_path, notice: 'School bus was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @school_bus.destroy
      redirect_to admin_school_buses_path, notice: 'School bus was successfully deleted.'
    end

    private

    def ensure_transport_permission!
      unless current_user.admin? || current_user.can_manage_transport?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access school buses.'
      end
    end

    def set_school_bus
      @school_bus = SchoolBus.find(params[:id])
    end

    def school_bus_params
      params.require(:school_bus).permit(:bus_number, :bus_model, :capacity, :description, :status)
    end
  end
end
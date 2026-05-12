module Admin
  class RoutesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_transport_permission!
    before_action :set_route, only: [:show, :edit, :update, :destroy]

    def index
      @routes = if current_user.admin?
                  Route.ordered.all
                else
                  Route.accessible_by(current_user).ordered
                end
    end

    def show
    end

    def new
      @route = Route.new
    end

    def create
      @route = Route.new(route_params)
      
      if @route.save
        redirect_to admin_routes_path, notice: 'Route was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @route.update(route_params)
        redirect_to admin_routes_path, notice: 'Route was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @route.destroy
      redirect_to admin_routes_path, notice: 'Route was successfully deleted.'
    end

    private

    def ensure_transport_permission!
      unless current_user.admin? || current_user.can_manage_transport?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access transport routes.'
      end
    end

    def set_route
      @route = Route.find(params[:id])
    end

    def route_params
      params.require(:route).permit(:name, :fare, :description)
    end
  end
end
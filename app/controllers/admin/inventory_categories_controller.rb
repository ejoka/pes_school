module Admin
  class InventoryCategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_inventory_permission!
    before_action :set_inventory_category, only: [:show, :edit, :update, :destroy]

    def index
      @inventory_categories = if current_user.admin?
                                InventoryCategory.ordered.all
                              else
                                InventoryCategory.accessible_by(current_user).ordered
                              end
    end

    def show
    end

    def new
      @inventory_category = InventoryCategory.new
    end

    def create
      @inventory_category = InventoryCategory.new(inventory_category_params)
      
      if @inventory_category.save
        redirect_to admin_inventory_categories_path, notice: 'Category was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @inventory_category.update(inventory_category_params)
        redirect_to admin_inventory_categories_path, notice: 'Category was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @inventory_category.destroy
      redirect_to admin_inventory_categories_path, notice: 'Category was successfully deleted.'
    end

    private

    def ensure_inventory_permission!
      unless current_user.admin? || current_user.can_manage_inventory?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access inventory categories.'
      end
    end

    def set_inventory_category
      @inventory_category = InventoryCategory.find(params[:id])
    end

    def inventory_category_params
      params.require(:inventory_category).permit(:name, :description)
    end
  end
end
# app/controllers/admin/inventory_items_controller.rb
module Admin
  class InventoryItemsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_inventory_permission!
    before_action :set_inventory_item, only: [:show, :edit, :update, :destroy]

    def index
      @inventory_items = if current_user.admin?
                           InventoryItem.includes(:inventory_category, :supplier).order(created_at: :desc)
                         else
                           InventoryItem.accessible_by(current_user).includes(:inventory_category, :supplier).order(created_at: :desc)
                         end
      
      # Statistics
      @total_items = @inventory_items.count
      @low_stock_items = @inventory_items.low_stock.count
      @out_of_stock_items = @inventory_items.out_of_stock.count
      @total_value = @inventory_items.sum(:quantity) * @inventory_items.average(:unit_price).to_i
    end

    def show
      @stock_movements = @inventory_item.stock_movements.order(date: :desc).limit(20)
    end

    def new
      @inventory_item = InventoryItem.new
      @categories = InventoryCategory.all.order(:name)
      @suppliers = Supplier.all.order(:name)
    end

    def create
      @inventory_item = InventoryItem.new(inventory_item_params)
      
      if @inventory_item.save
        redirect_to admin_inventory_items_path, notice: 'Inventory item was successfully created.'
      else
        @categories = InventoryCategory.all.order(:name)
        @suppliers = Supplier.all.order(:name)
        render :new
      end
    end

    def edit
      @categories = InventoryCategory.all.order(:name)
      @suppliers = Supplier.all.order(:name)
    end

    def update
      if @inventory_item.update(inventory_item_params)
        redirect_to admin_inventory_items_path, notice: 'Inventory item was successfully updated.'
      else
        @categories = InventoryCategory.all.order(:name)
        @suppliers = Supplier.all.order(:name)
        render :edit
      end
    end

    def destroy
      @inventory_item.destroy
      redirect_to admin_inventory_items_path, notice: 'Inventory item was successfully deleted.'
    end

    def low_stock
      @inventory_items = InventoryItem.low_stock.includes(:inventory_category, :supplier)
      render :index
    end

    private

    def ensure_inventory_permission!
      unless current_user.admin? || current_user.can_manage_inventory?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access inventory.'
      end
    end

    def set_inventory_item
      @inventory_item = InventoryItem.find(params[:id])
    end

    def inventory_item_params
      params.require(:inventory_item).permit(:name, :inventory_category_id, :supplier_id, :quantity, :minimum_stock, :unit, :unit_price, :location, :description)
    end
  end
end
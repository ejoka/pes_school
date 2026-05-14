module Admin
  class StockMovementsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_inventory_permission!
    before_action :set_inventory_item

    def new
      @stock_movement = @inventory_item.stock_movements.new
      @stock_movement.date = Date.today
    end

    def create
      @stock_movement = @inventory_item.stock_movements.new(stock_movement_params)
      @stock_movement.user = current_user
      
      if @stock_movement.save
        redirect_to admin_inventory_item_path(@inventory_item), notice: 'Stock movement was successfully recorded.'
      else
        render :new
      end
    end

    private

    def ensure_inventory_permission!
      unless current_user.admin? || current_user.can_manage_inventory?(:edit)
        redirect_to dashboard_path, alert: 'You do not have permission to manage stock movements.'
      end
    end

    def set_inventory_item
      @inventory_item = InventoryItem.find(params[:item_id])
    end

    def stock_movement_params
      params.require(:stock_movement).permit(:movement_type, :quantity, :reference_number, :date, :notes)
    end
  end
end
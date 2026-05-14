module Admin
  class StockMovementsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_inventory_permission!
    before_action :set_inventory_item, only: [:new, :create]
    before_action :set_stock_movement, only: [:destroy]

    def index
      @stock_movements = if current_user.admin?
                           StockMovement.includes(:inventory_item, :user).order(date: :desc)
                         else
                           StockMovement.accessible_by(current_user).includes(:inventory_item, :user).order(date: :desc)
                         end
    end

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

    def destroy
      @stock_movement.destroy
      redirect_to admin_stock_movements_path, notice: 'Stock movement was successfully deleted.'
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

    def set_stock_movement
      @stock_movement = StockMovement.find(params[:id])
    end

    def stock_movement_params
      params.require(:stock_movement).permit(:movement_type, :quantity, :reference_number, :date, :notes)
    end
  end
end
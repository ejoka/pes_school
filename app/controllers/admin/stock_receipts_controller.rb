module Admin
  class StockReceiptsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_inventory_permission!
    before_action :set_stock_receipt, only: [:show, :edit, :update, :destroy, :receive, :cancel]

    def index
      @stock_receipts = if current_user.admin?
                          StockReceipt.includes(:supplier, :user).order(created_at: :desc)
                        else
                          StockReceipt.accessible_by(current_user).includes(:supplier, :user).order(created_at: :desc)
                        end
    end

    def show
      @items = @stock_receipt.stock_receipt_items.includes(:inventory_item)
    end

    def new
      @stock_receipt = StockReceipt.new
      @suppliers = Supplier.all.order(:name)
      @inventory_items = InventoryItem.all.order(:name)
    end

    def create
      @stock_receipt = StockReceipt.new(stock_receipt_params)
      @stock_receipt.user = current_user
      @stock_receipt.status = 'pending'
      
      if @stock_receipt.save
        # Save receipt items
        if params[:items].present?
          params[:items].each do |item|
            StockReceiptItem.create(
              stock_receipt: @stock_receipt,
              inventory_item_id: item[:inventory_item_id],
              quantity: item[:quantity],
              unit_price: item[:unit_price]
            )
          end
        end
        redirect_to admin_stock_receipt_path(@stock_receipt), notice: 'Stock receipt was successfully created.'
      else
        @suppliers = Supplier.all.order(:name)
        @inventory_items = InventoryItem.all.order(:name)
        render :new
      end
    end

    def receive
      @stock_receipt.update(status: 'received')
      # Create stock movements for each item
      @stock_receipt.stock_receipt_items.each do |item|
        StockMovement.create(
          inventory_item: item.inventory_item,
          movement_type: 'receive',
          quantity: item.quantity,
          date: @stock_receipt.received_date,
          reference_number: @stock_receipt.receipt_number,
          user: current_user
        )
      end
      redirect_to admin_stock_receipt_path(@stock_receipt), notice: 'Stock receipt was confirmed and stock updated.'
    end

    def cancel
      @stock_receipt.update(status: 'cancelled')
      redirect_to admin_stock_receipts_path, notice: 'Stock receipt was cancelled.'
    end

    def destroy
      @stock_receipt.destroy
      redirect_to admin_stock_receipts_path, notice: 'Stock receipt was successfully deleted.'
    end

    private

    def ensure_inventory_permission!
      unless current_user.admin? || current_user.can_manage_inventory?(:edit)
        redirect_to dashboard_path, alert: 'You do not have permission to manage stock receipts.'
      end
    end

    def set_stock_receipt
      @stock_receipt = StockReceipt.find(params[:id])
    end

    def stock_receipt_params
      params.require(:stock_receipt).permit(:supplier_id, :received_date, :notes)
    end
  end
end
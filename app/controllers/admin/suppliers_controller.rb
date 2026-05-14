module Admin
  class SuppliersController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_inventory_permission!
    before_action :set_supplier, only: [:show, :edit, :update, :destroy]

    def index
      @suppliers = if current_user.admin?
                     Supplier.ordered.all
                   else
                     Supplier.accessible_by(current_user).ordered
                   end
    end

    def show
    end

    def new
      @supplier = Supplier.new
    end

    def create
      @supplier = Supplier.new(supplier_params)
      
      if @supplier.save
        redirect_to admin_suppliers_path, notice: 'Supplier was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @supplier.update(supplier_params)
        redirect_to admin_suppliers_path, notice: 'Supplier was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @supplier.destroy
      redirect_to admin_suppliers_path, notice: 'Supplier was successfully deleted.'
    end

    private

    def ensure_inventory_permission!
      unless current_user.admin? || current_user.can_manage_inventory?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access suppliers.'
      end
    end

    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    def supplier_params
      params.require(:supplier).permit(:name, :contact_person, :phone, :email, :address, :notes)
    end
  end
end
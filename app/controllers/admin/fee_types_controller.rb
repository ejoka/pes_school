class Admin::FeeTypesController < ApplicationController
  before_action :ensure_admin!
  before_action :set_fee_type, only: [:edit, :update, :destroy]

  def index
    @fee_types = FeeType.all.order(:name)
  end

  def new
    @fee_type = FeeType.new
  end

  def create
    @fee_type = FeeType.new(fee_type_params)
    if @fee_type.save
      redirect_to admin_fee_types_path, notice: 'Fee type was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @fee_type.update(fee_type_params)
      redirect_to admin_fee_types_path, notice: 'Fee type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @fee_type.fees.any?
      redirect_to admin_fee_types_path, alert: 'Cannot delete fee type that has associated fees.'
    else
      @fee_type.destroy
      redirect_to admin_fee_types_path, notice: 'Fee type was successfully deleted.'
    end
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def set_fee_type
    @fee_type = FeeType.find(params[:id])
  end

  def fee_type_params
    params.require(:fee_type).permit(:name, :description)
  end
end
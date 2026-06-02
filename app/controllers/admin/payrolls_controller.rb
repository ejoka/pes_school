module Admin
  class PayrollsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_staff_permission!
    before_action :set_payroll, only: [:show, :edit, :update, :destroy, :mark_paid]

    def index
      @payrolls = []
      
      begin
        if current_user.admin?
          @payrolls = Payroll.includes(staff_assignment: [:user, :department]).order(year: :desc, month: :desc).to_a
        else
          @payrolls = Payroll.accessible_by(current_user).includes(staff_assignment: [:user, :department]).order(year: :desc, month: :desc).to_a
        end
      rescue => e
        Rails.logger.error "Error fetching payrolls: #{e.message}"
        @payrolls = []
      end
      
      @payrolls ||= []
    end

    def show
    end

    def new
      @payroll = Payroll.new
      @staff_members = StaffAssignment.active.includes(:user).to_a
    end

    def create
      @payroll = Payroll.new(payroll_params)
      if @payroll.save
        redirect_to admin_payrolls_path, notice: 'Payroll was successfully created.'
      else
        @staff_members = StaffAssignment.active.includes(:user).to_a
        render :new
      end
    end

    def edit
      @staff_members = StaffAssignment.active.includes(:user).to_a
    end

    def update
      if @payroll.update(payroll_params)
        redirect_to admin_payrolls_path, notice: 'Payroll was successfully updated.'
      else
        @staff_members = StaffAssignment.active.includes(:user).to_a
        render :edit
      end
    end

    def destroy
      @payroll.destroy
      redirect_to admin_payrolls_path, notice: 'Payroll was successfully deleted.'
    end

    def mark_paid
      if @payroll.update(status: 'paid', payment_date: Date.today)
        redirect_to admin_payrolls_path, notice: 'Payroll was marked as paid successfully.'
      else
        redirect_to admin_payrolls_path, alert: 'Failed to mark payroll as paid.'
      end
    end

    private

    def ensure_staff_permission!
      unless current_user.admin? || current_user.can_manage_staff?(:edit)
        redirect_to dashboard_path, alert: 'You do not have permission to access payroll.'
      end
    end

    def set_payroll
      @payroll = Payroll.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_payrolls_path, alert: 'Payroll record not found.'
    end

    def payroll_params
      params.require(:payroll).permit(:staff_assignment_id, :month, :year, :basic_salary, :allowances, :deductions, :status, :notes)
    end
  end
end
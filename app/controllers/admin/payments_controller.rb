class Admin::PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_payment_permission!
  before_action :set_student
  before_action :set_payment, only: [:destroy]

  def index
    @payments = @student.payments.order(payment_date: :desc)
    @total_paid = @payments.sum(:amount)
    @can_edit = current_user.can_manage_fees?(:edit)
    @can_delete = current_user.can_manage_fees?(:delete)
  end

  def new
    unless current_user.can_manage_fees?(:create)
      redirect_to admin_student_payments_path(@student), alert: 'You do not have permission to record payments.'
      return
    end
    
    @payment = @student.payments.new
    @unpaid_fees = @student.student_fees.where(is_paid: false)
  end

  def create
    unless current_user.can_manage_fees?(:create)
      redirect_to admin_student_payments_path(@student), alert: 'You do not have permission to record payments.'
      return
    end
    
    @payment = @student.payments.new(payment_params)
    @payment.created_by = current_user
    
    if params[:apply_to_fee].present?
      @payment.payable_type = 'StudentFee'
      @payment.payable_id = params[:fee_id]
    end
    
    if @payment.save
      redirect_to admin_student_payments_path(@student), notice: 'Payment was successfully recorded.'
    else
      @unpaid_fees = @student.student_fees.where(is_paid: false)
      render :new
    end
  end

  def destroy
    unless current_user.can_manage_fees?(:delete)
      redirect_to admin_student_payments_path(@student), alert: 'You do not have permission to delete payments.'
      return
    end
    
    @payment.destroy
    redirect_to admin_student_payments_path(@student), notice: 'Payment was successfully deleted.'
  end

  private

  def ensure_payment_permission!
    unless current_user.admin? || current_user.can_manage_fees?(:view)
      redirect_to dashboard_path, alert: 'You do not have permission to access payments.'
    end
  end

  def set_student
    @student = Student.find(params[:student_id])
  end

  def set_payment
    @payment = @student.payments.find(params[:id])
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_date, :payment_method, :reference, :notes)
  end
end
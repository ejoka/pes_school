class Admin::AllPaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_payment_permission!

  def index
    if current_user.admin?
      @payments = Payment.all.includes(:student, :created_by).order(payment_date: :desc)
      @payment_methods = Payment.group(:payment_method).sum(:amount)
    else
      student_ids = current_user.accessible_students.pluck(:id)
      @payments = Payment.where(created_by_id: current_user.id)
                        .or(Payment.where(student_id: student_ids))
                        .includes(:student, :created_by)
                        .order(payment_date: :desc)
      @payment_methods = Payment.where(created_by_id: current_user.id)
                               .or(Payment.where(student_id: student_ids))
                               .group(:payment_method)
                               .sum(:amount)
    end
    
    @total_payments = @payments.sum(:amount)
  end

  private

  def ensure_payment_permission!
    unless current_user.admin? || current_user.can_manage_fees?(:view)
      redirect_to dashboard_path, alert: 'You do not have permission to access payments.'
    end
  end
end
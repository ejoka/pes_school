class Admin::FeesController < ApplicationController
  before_action :ensure_admin!
  before_action :set_fee, only: [:show, :edit, :update, :destroy, :record_payment]
  before_action :set_student, only: [:student_fees, :new, :create, :record_payment]

  def index
    @fees = Fee.includes(:student, :fee_type).order(created_at: :desc)
    @total_collected = Fee.sum(:amount_paid)
    @total_expected = Fee.sum(:amount_to_pay)
    @outstanding_balance = @total_expected - @total_collected
  end

  def show
    @payments = @fee.payments.order(payment_date: :desc)
  end

  def new
    @fee = Fee.new
    @fee.student = @student if @student
    @fee_types = FeeType.all.order(:name)
  end

  def create
    @fee = Fee.new(fee_params)
    @fee.student = @student if @student && !fee_params[:student_id]
    
    if @fee.save
      redirect_to admin_fees_path, notice: 'Fee record was successfully created.'
    else
      @fee_types = FeeType.all.order(:name)
      render :new
    end
  end

  def edit
    @fee_types = FeeType.all.order(:name)
  end

  def update
    if @fee.update(fee_params)
      redirect_to admin_fees_path, notice: 'Fee record was successfully updated.'
    else
      @fee_types = FeeType.all.order(:name)
      render :edit
    end
  end

  def destroy
    @fee.destroy
    redirect_to admin_fees_path, notice: 'Fee record was successfully deleted.'
  end

  def student_fees
    @fees = @student.fees.includes(:fee_type).order(due_date: :desc)
    @total_paid = @fees.sum(:amount_paid)
    @total_due = @fees.sum(:amount_to_pay)
    @balance = @total_due - @total_paid
  end

  def record_payment
    @payment = Payment.new
    @payment.fee = @fee
    @payment.student = @fee.student
  end

  def save_payment
    @fee = Fee.find(params[:fee_id])
    @payment = Payment.new(payment_params)
    @payment.fee = @fee
    @payment.student = @fee.student
    
    if @payment.save
      redirect_to admin_fee_path(@fee), notice: 'Payment was successfully recorded.'
    else
      render :record_payment
    end
  end

  def bulk_fees
    if request.post?
      @students = Student.where(school_class_id: params[:class_id])
      @fee_type = FeeType.find(params[:fee_type_id])
      @amount = params[:amount].to_d
      @due_date = params[:due_date]
      
      @students.each do |student|
        Fee.create(
          student: student,
          fee_type: @fee_type,
          amount_to_pay: @amount,
          amount_paid: 0,
          due_date: @due_date
        )
      end
      
      redirect_to admin_fees_path, notice: "Bulk fees created for #{@students.count} students."
    else
      @fee_types = FeeType.all.order(:name)
      @classes = SchoolClass.all.order(:name)
    end
  end

  def create_fee_type
    @fee_type = FeeType.new(name: params[:name], description: params[:description])
    if @fee_type.save
      render json: { id: @fee_type.id, name: @fee_type.name, success: true }
    else
      render json: { errors: @fee_type.errors.full_messages, success: false }, status: :unprocessable_entity
    end
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def set_fee
    @fee = Fee.find(params[:id])
  end

  def set_student
    @student = Student.find(params[:student_id]) if params[:student_id]
  end

  def fee_params
    params.require(:fee).permit(:student_id, :fee_type_id, :amount_to_pay, :amount_paid, :due_date, :notes)
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_date, :payment_method, :reference_number, :notes)
  end
end
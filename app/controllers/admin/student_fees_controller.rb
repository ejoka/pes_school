class Admin::StudentFeesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_fee_permission!
  before_action :set_student, except: [:all_students]
  before_action :set_student_fee, only: [:edit, :update, :destroy]

  def index
    @student_fees = @student.student_fees.includes(:fee_category).order(:due_date)
    @total_due = @student.student_fees.sum(:amount)
    @total_paid = @student.payments.sum(:amount)
    @balance = @total_due - @total_paid
    @can_edit = current_user.can_manage_fees?(:edit)
    @can_delete = current_user.can_manage_fees?(:delete)
  end

  def new
    unless current_user.can_manage_fees?(:create)
      redirect_to admin_student_student_fees_path(@student), alert: 'You do not have permission to add fees.'
      return
    end
    @student_fee = @student.student_fees.new
    @fee_categories = FeeCategory.all.order(:name)
    
    if @fee_categories.empty?
      flash[:warning] = 'No fee categories found. Please run rails db:seed to create fee categories.'
    end
  end

  def create
    unless current_user.can_manage_fees?(:create)
      redirect_to admin_student_student_fees_path(@student), alert: 'You do not have permission to add fees.'
      return
    end
    
    @student_fee = @student.student_fees.new(student_fee_params)
    
    if @student_fee.save
      redirect_to admin_student_student_fees_path(@student), notice: 'Fee was successfully added.'
    else
      @fee_categories = FeeCategory.all.order(:name)
      render :new
    end
  end

  def edit
    unless current_user.can_manage_fees?(:edit)
      redirect_to admin_student_student_fees_path(@student), alert: 'You do not have permission to edit fees.'
      return
    end
    @fee_categories = FeeCategory.all.order(:name)
  end

  def update
    unless current_user.can_manage_fees?(:edit)
      redirect_to admin_student_student_fees_path(@student), alert: 'You do not have permission to update fees.'
      return
    end
    
    if @student_fee.update(student_fee_params)
      redirect_to admin_student_student_fees_path(@student), notice: 'Fee was successfully updated.'
    else
      @fee_categories = FeeCategory.all.order(:name)
      render :edit
    end
  end

  def destroy
    unless current_user.can_manage_fees?(:delete)
      redirect_to admin_student_student_fees_path(@student), alert: 'You do not have permission to delete fees.'
      return
    end
    
    @student_fee.destroy
    redirect_to admin_student_student_fees_path(@student), notice: 'Fee was successfully removed.'
  end

  def bulk_add
    unless current_user.can_manage_fees?(:create)
      redirect_to admin_student_student_fees_path(@student), alert: 'You do not have permission to add fees.'
      return
    end
    
    if request.post?
      fee_category_ids = params[:fee_category_ids]
      due_date = params[:due_date]
      
      if fee_category_ids.present?
        fee_category_ids.each do |category_id|
          amount = params["amount_#{category_id}"].to_f
          if amount > 0
            @student.student_fees.create(
              fee_category_id: category_id,
              amount: amount,
              due_date: due_date
            )
          end
        end
        redirect_to admin_student_student_fees_path(@student), notice: 'Bulk fees were successfully added.'
      else
        flash[:alert] = 'Please select at least one fee category.'
        @fee_categories = FeeCategory.all.order(:name)
        render :bulk_add
      end
    else
      @fee_categories = FeeCategory.all.order(:name)
    end
  end

  def generate_invoice
    unless current_user.can_generate_invoice?
      redirect_to admin_student_student_fees_path(@student), alert: 'You do not have permission to generate invoices.'
      return
    end
    
    @invoice_data = @student.generate_invoice
    @generated_by = current_user.full_name
    
    render :generate_invoice
  end
  
  def all_students
    unless current_user.can_manage_fees?(:view)
      redirect_to dashboard_path, alert: 'You do not have permission to view all student fees.'
      return
    end
    
    @students = Student.all.includes(:school_class, :student_fees, :payments)
    @total_fees = StudentFee.sum(:amount)
    @total_paid = Payment.sum(:amount)
    @outstanding = @total_fees - @total_paid
    
    # Statistics by fee category
    @category_stats = FeeCategory.left_joins(:student_fees)
                                 .group('fee_categories.name', 'fee_categories.id')
                                 .sum('student_fees.amount')
  end

  private

  def ensure_fee_permission!
    unless current_user.admin? || current_user.can_manage_fees?(:view)
      redirect_to dashboard_path, alert: 'You do not have permission to access fee management.'
    end
  end

  def set_student
    @student = Student.find(params[:student_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_all_students_fees_path, alert: 'Student not found.'
  end

  def set_student_fee
    @student_fee = @student.student_fees.find(params[:id])
  end

  def student_fee_params
    params.require(:student_fee).permit(:fee_category_id, :amount, :due_date)
  end
end
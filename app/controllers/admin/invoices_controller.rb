class Admin::InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_invoice_permission!
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :send_invoice, :download_pdf]
  before_action :set_student, only: [:new, :create, :student_invoices]

  def index
    if current_user.admin?
      @invoices = Invoice.all.includes(:student, :created_by).order(created_at: :desc)
    else
      student_ids = current_user.accessible_students.pluck(:id)
      @invoices = Invoice.where(created_by_id: current_user.id)
                        .or(Invoice.where(student_id: student_ids))
                        .includes(:student, :created_by)
                        .order(created_at: :desc)
    end
    
    @total_revenue = Invoice.sum(:paid_amount)
    @total_invoiced = Invoice.sum(:total_amount)
    @outstanding_invoices = @total_invoiced - @total_revenue
  end

  def show
    @payments = @invoice.payments.order(payment_date: :desc)
    @student_fees = @invoice.student_fees.includes(:fee_category)
  end

  def new
    @invoice = Invoice.new
    @invoice.generated_date = Date.today
    @invoice.due_date = Date.today + 30.days
    @unpaid_fees = @student.student_fees.where(is_paid: false)
  end

  def create
    unless @student
      redirect_to admin_all_students_fees_path, alert: 'Student not found.'
      return
    end
    
    if params[:fee_ids].blank? || params[:fee_ids].reject(&:blank?).empty?
      @unpaid_fees = @student.student_fees.where(is_paid: false)
      flash.now[:alert] = 'Please select at least one fee to invoice.'
      render :new
      return
    end
    
    selected_fee_ids = params[:fee_ids].reject(&:blank?)
    selected_fees = StudentFee.where(id: selected_fee_ids)
    
    if selected_fees.empty?
      @unpaid_fees = @student.student_fees.where(is_paid: false)
      flash.now[:alert] = 'Selected fees are invalid or already paid.'
      render :new
      return
    end
    
    # Calculate totals - iterate through selected fees to get amounts
    total_amount = 0
    selected_fees.each do |fee|
      total_amount += fee.amount - fee.amount_paid
    end
    
    @invoice = Invoice.new
    @invoice.student = @student
    @invoice.created_by_id = current_user.id
    @invoice.generated_date = Date.today
    @invoice.due_date = params[:invoice][:due_date] if params[:invoice].present?
    @invoice.due_date ||= Date.today + 30.days
    @invoice.total_amount = total_amount
    @invoice.paid_amount = 0
    @invoice.status = 'sent'
    @invoice.invoice_number = generate_invoice_number
    
    if @invoice.save
      selected_fees.update_all(invoice_id: @invoice.id)
      redirect_to admin_student_invoice_path(@student, @invoice), notice: 'Invoice was successfully created.'
    else
      @unpaid_fees = @student.student_fees.where(is_paid: false)
      render :new
    end
  end

  def edit
    @student = @invoice.student
    @unpaid_fees = @student.student_fees.where(is_paid: false)
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to admin_student_invoice_path(@student, @invoice), notice: 'Invoice was successfully updated.'
    else
      @student = @invoice.student
      @unpaid_fees = @student.student_fees.where(is_paid: false)
      render :edit
    end
  end

  def destroy
    @student = @invoice.student
    @invoice.student_fees.update_all(invoice_id: nil)
    @invoice.destroy
    redirect_to student_invoices_admin_student_invoices_path(@student), notice: 'Invoice was successfully deleted.'
  end

  def send_invoice
    @invoice.update(status: 'sent')
    redirect_to admin_student_invoice_path(@student, @invoice), notice: 'Invoice was sent successfully.'
  end

  def download_pdf
    redirect_to admin_student_invoice_path(@student, @invoice), notice: 'PDF download feature coming soon.'
  end

  def student_invoices
    @invoices = @student.invoices.order(created_at: :desc)
  end

  def refresh
    if @invoice
      @invoice.update_totals_from_fees
      redirect_to admin_student_invoice_path(@student, @invoice), notice: 'Invoice totals have been refreshed.'
    else
      redirect_to admin_all_invoices_path, alert: 'Invoice not found.'
    end
  end

  private

  def ensure_invoice_permission!
    unless current_user.admin? || current_user.can_manage_fees?(:view)
      redirect_to dashboard_path, alert: 'You do not have permission to access invoices.'
    end
  end

  def set_invoice
    @invoice = Invoice.find(params[:id])
    @student = @invoice.student
  end

  def set_student
    @student = Student.find(params[:student_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_all_students_fees_path, alert: 'Student not found.'
  end

  def invoice_params
    params.require(:invoice).permit(:due_date, :notes)
  end
  
  def generate_invoice_number
    year = Time.now.strftime('%Y')
    month = Time.now.strftime('%m')
    count = Invoice.where("invoice_number LIKE ?", "INV-#{year}#{month}-%").count + 1
    "INV-#{year}#{month}-#{count.to_s.rjust(4, '0')}"
  end
end
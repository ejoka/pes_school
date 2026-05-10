class Admin::InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_invoice_permission!
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :send_invoice, :download_pdf]
  before_action :set_student, only: [:new, :create, :student_invoices]

  def index
    # For admin - show all invoices
    # For non-admin - show invoices they created or invoices for students they have access to
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
    @invoice = Invoice.new(invoice_params)
    @invoice.student = @student
    @invoice.created_by_id = current_user.id
    @invoice.generated_date = Date.today
    
    if params[:fee_ids].present?
      selected_fees = StudentFee.where(id: params[:fee_ids])
      
      # Calculate totals
      total_amount = selected_fees.sum(:amount) - selected_fees.sum(:paid)
      
      @invoice.total_amount = total_amount
      @invoice.paid_amount = 0
      @invoice.status = 'sent'
      
      if @invoice.save
        # Associate fees with invoice
        selected_fees.update_all(invoice_id: @invoice.id)
        redirect_to admin_student_invoice_path(@student, @invoice), notice: 'Invoice was successfully created.'
      else
        @unpaid_fees = @student.student_fees.where(is_paid: false)
        render :new
      end
    else
      @unpaid_fees = @student.student_fees.where(is_paid: false)
      flash.now[:alert] = 'Please select at least one fee to invoice.'
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
    # Remove invoice association from fees before destroying
    @invoice.student_fees.update_all(invoice_id: nil)
    @invoice.destroy
    redirect_to admin_student_invoices_path(@student), notice: 'Invoice was successfully deleted.'
  end

  def send_invoice
    @invoice.update(status: 'sent')
    redirect_to admin_student_invoice_path(@student, @invoice), notice: 'Invoice was sent successfully.'
  end

  def download_pdf
    # Here you would implement PDF generation
    redirect_to admin_student_invoice_path(@student, @invoice), notice: 'PDF download feature coming soon.'
  end

  def student_invoices
    @invoices = @student.invoices.order(created_at: :desc)
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
  end

  def invoice_params
    params.require(:invoice).permit(:due_date, :notes)
  end
end
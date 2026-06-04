module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!
    layout 'application'

    def index
      # Basic Stats
      @total_students = Student.count
      @total_teachers = User.where(professional_type: 'Teacher').count
      @total_staff = StaffAssignment.active.count
      @total_classes = SchoolClass.count
      
      # Fee Statistics
      @total_fees_collected = Payment.sum(:amount)
      @total_fees_expected = StudentFee.sum(:amount)
      @outstanding_fees = @total_fees_expected - @total_fees_collected
      @collection_rate = @total_fees_expected > 0 ? (@total_fees_collected / @total_fees_expected * 100).round(1) : 0
      
      # Attendance Statistics (Current Month)
      current_month = Date.today.beginning_of_month..Date.today.end_of_month
      @total_attendance_days = AttendanceRecord.where(date: current_month).count
      @present_attendance = AttendanceRecord.where(date: current_month).present.count
      @attendance_rate = @total_attendance_days > 0 ? (@present_attendance.to_f / @total_attendance_days * 100).round(1) : 0
      
      # Monthly Fee Collection Data (Last 12 months)
      @monthly_fee_data = []
      @monthly_fee_labels = []
      12.times do |i|
        month = Date.today.beginning_of_month - i.months
        monthly_collected = Payment.where(payment_date: month.beginning_of_month..month.end_of_month).sum(:amount)
        @monthly_fee_data.unshift(monthly_collected.to_i)
        @monthly_fee_labels.unshift(month.strftime("%b %Y"))
      end
      
      # Student Enrollment by Class
      @class_enrollment_data = SchoolClass.includes(:students).map { |c| c.students.count }
      @class_enrollment_labels = SchoolClass.pluck(:name)
      
      # Fee Collection by Category
      @fee_category_data = FeeCategory.left_joins(:student_fees)
                                      .group(:name)
                                      .sum('student_fees.amount')
      @fee_category_labels = @fee_category_data.keys
      @fee_category_values = @fee_category_data.values.map(&:to_i)
      
      # Recent Activities
      @recent_payments = Payment.includes(:student).order(payment_date: :desc).limit(5)
      @recent_attendance = AttendanceRecord.includes(:student).order(date: :desc).limit(5)
      @recent_invoices = Invoice.includes(:student).order(created_at: :desc).limit(5)
      
      # Top Performing Classes (by attendance)
      @top_classes = SchoolClass.left_joins(:students)
                                .group(:id)
                                .select('school_classes.*, COUNT(students.id) as student_count')
                                .order('student_count DESC')
                                .limit(5)
      
      # Gender Distribution
      @male_students = Student.where(gender: 'Male').count
      @female_students = Student.where(gender: 'Female').count
      @other_students = Student.where(gender: 'Other').count
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
    end
  end
end
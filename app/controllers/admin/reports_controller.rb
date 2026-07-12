module Admin
  class ReportsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_report_permission!
    layout 'application'

    def index
      @reports = {
        staff: {
          attendance: { path: staff_attendance_report_admin_reports_path, icon: 'attendance' },
          payroll: { path: staff_payroll_report_admin_reports_path, icon: 'payroll' }
        },
        exam: {
          performance: { path: exam_performance_report_admin_reports_path, icon: 'performance' },
          subject: { path: exam_subject_report_admin_reports_path, icon: 'subject' }
        },
        student: {
          attendance: { path: student_attendance_report_admin_reports_path, icon: 'attendance' },
          performance: { path: student_performance_report_admin_reports_path, icon: 'performance' }
        },
        fees: {
          fees: { path: fees_report_admin_reports_path, icon: 'fees' }
        },
        transport: {
          transport: { path: transport_report_admin_reports_path, icon: 'transport' }
        },
        inventory: {
          inventory: { path: inventory_report_admin_reports_path, icon: 'inventory' }
        }
      }
    end
  
    # Staff Reports
    def staff_attendance_report
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.end_of_month
      
      @staff_attendances = StaffAttendanceRecord.where(date: @start_date..@end_date)
                                               .includes(staff_assignment: [:user, :department])
      @summary = {
        total_staff: @staff_attendances.map(&:staff_assignment_id).uniq.count,
        total_present: @staff_attendances.present.count,
        total_absent: @staff_attendances.absent.count,
        total_late: @staff_attendances.late.count,
        total_leave: @staff_attendances.leave.count,
        attendance_rate: @staff_attendances.count > 0 ? (@staff_attendances.present.count.to_f / @staff_attendances.count * 100).round(1) : 0
      }
      
      @department_stats = @staff_attendances.joins(staff_assignment: :department)
                                            .group('departments.name')
                                            .count
    end

    def staff_payroll_report
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_year
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.end_of_year
      
      @payrolls = Payroll.where(payment_date: @start_date..@end_date)
                        .includes(staff_assignment: [:user, :department])
      
      @summary = {
        total_paid: @payrolls.sum(:net_salary),
        total_staff: @payrolls.map(&:staff_assignment_id).uniq.count,
        average_salary: @payrolls.average(:net_salary).to_f.round(2),
        total_deductions: @payrolls.sum(:deductions),
        total_allowances: @payrolls.sum(:allowances)
      }
      
      @department_stats = @payrolls.joins(staff_assignment: :department)
                                  .group('departments.name')
                                  .sum(:net_salary)
      
      @monthly_stats = @payrolls.group(:month, :year).sum(:net_salary)
    end

    # Exam Reports
    def exam_performance_report
      @exam_type_id = params[:exam_type_id]
      @exam_schedule_id = params[:exam_schedule_id]
      
      @exam_types = ExamType.all
      @exam_schedules = ExamSchedule.all
      
      @marks = EnterMark.includes(:student, :subject, :exam_attendance)
      @marks = @marks.where(exam_attendance: { exam_schedule_id: @exam_schedule_id }) if @exam_schedule_id.present?
      
      @summary = {
        total_students: @marks.map(&:student_id).uniq.count,
        average_percentage: @marks.average(:percentage).to_f.round(2),
        pass_count: @marks.select { |m| m.status == 'pass' }.count,
        fail_count: @marks.select { |m| m.status == 'fail' }.count,
        pass_rate: @marks.count > 0 ? (@marks.select { |m| m.status == 'pass' }.count.to_f / @marks.count * 100).round(1) : 0
      }
      
      @grade_distribution = @marks.group(:grade).count
      @subject_performance = @marks.group(:subject_id).average(:percentage)
    end

    def exam_subject_report
      @subject_id = params[:subject_id]
      
      @subjects = Subject.all
      @marks = EnterMark.includes(:student, :exam_attendance)
      @marks = @marks.where(subject_id: @subject_id) if @subject_id.present?
      
      @summary = {
        total_exams: @marks.map(&:exam_attendance_id).uniq.count,
        total_students: @marks.map(&:student_id).uniq.count,
        average_mark: @marks.average(:marks_obtained).to_f.round(2),
        highest_mark: @marks.maximum(:marks_obtained).to_f,
        lowest_mark: @marks.minimum(:marks_obtained).to_f
      }
      
      @performance_trend = @marks.group(:exam_attendance_id).average(:percentage)
    end

    # Student Reports
    def student_attendance_report
      @class_id = params[:class_id]
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_month
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.end_of_month
      
      @classes = SchoolClass.all
      
      @attendances = AttendanceRecord.where(date: @start_date..@end_date)
      @attendances = @attendances.where(school_class_id: @class_id) if @class_id.present?
      
      @summary = {
        total_students: @attendances.map(&:student_id).uniq.count,
        total_present: @attendances.present.count,
        total_absent: @attendances.absent.count,
        total_late: @attendances.late.count,
        attendance_rate: @attendances.count > 0 ? (@attendances.present.count.to_f / @attendances.count * 100).round(1) : 0
      }
      
      @class_stats = @attendances.joins(:school_class)
                                .group('school_classes.name')
                                .count
    end

    def student_performance_report
      @class_id = params[:class_id]
      @exam_type_id = params[:exam_type_id]
      
      @classes = SchoolClass.all
      @exam_types = ExamType.all
      
      @marks = EnterMark.includes(:student, :subject)
      @marks = @marks.where(school_class_id: @class_id) if @class_id.present?
      @marks = @marks.joins(:exam_attendance).where(exam_attendances: { exam_schedule_id: @exam_type_id }) if @exam_type_id.present?
      
      @summary = {
        total_students: @marks.map(&:student_id).uniq.count,
        total_subjects: @marks.map(&:subject_id).uniq.count,
        average_percentage: @marks.average(:percentage).to_f.round(2),
        top_performer: @marks.group(:student_id).average(:percentage).max.to_f
      }
      
      @top_students = @marks.group(:student_id).average(:percentage)
                           .sort_by { |_, avg| -avg }.first(10)
    end

    # Fees Report
    def fees_report
      @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_year
      @end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today.end_of_year
      
      @payments = Payment.where(payment_date: @start_date..@end_date)
                        .includes(:student)
      
      @fee_types = FeeCategory.all
      
      @summary = {
        total_collected: @payments.sum(:amount),
        total_transactions: @payments.count,
        average_payment: @payments.average(:amount).to_f.round(2),
        collection_rate: StudentFee.sum(:amount) > 0 ? (@payments.sum(:amount) / StudentFee.sum(:amount) * 100).round(1) : 0
      }
      
      @monthly_collection = @payments.group(:payment_date).sum(:amount)
      @fee_type_collection = FeeCategory.left_joins(:student_fees)
                                    .group(:name)
                                    .sum('student_fees.amount')
      @pending_fees = StudentFee.where('amount_paid < amount').count
    end

    # Transport Report
    def transport_report
      @route_id = params[:route_id]
      
      @routes = Route.all
      @assignments = StudentTransportAssignment.includes(:student, :route)
      @assignments = @assignments.where(route_id: @route_id) if @route_id.present?
      
      @summary = {
        total_students: @assignments.count,
        total_routes: @routes.count,
        active_assignments: @assignments.active.count,
        total_revenue: @assignments.joins(:route).sum('routes.fare')
      }
      
      @route_stats = @assignments.group(:route_id).count
      @bus_utilization = SchoolBus.left_joins(:bus_route_assignments)
                                  .group(:bus_number)
                                  .count
    end

    # Inventory Report
    def inventory_report
      @category_id = params[:category_id]
      
      @categories = InventoryCategory.all
      @items = InventoryItem.includes(:inventory_category)
      @items = @items.where(inventory_category_id: @category_id) if @category_id.present?
      
      @summary = {
        total_items: @items.count,
        total_value: @items.sum(:quantity) * @items.average(:unit_price).to_i,
        low_stock_items: @items.low_stock.count,
        out_of_stock_items: @items.out_of_stock.count,
        total_movements: StockMovement.count
      }
      
      @category_stats = @items.group(:inventory_category_id).count
      @low_stock_list = @items.low_stock
      @recent_movements = StockMovement.includes(:inventory_item).order(date: :desc).limit(10)
    end

    private

    def ensure_report_permission!
      unless current_user.admin?
        redirect_to dashboard_path, alert: 'You do not have permission to access reports.'
      end
    end
  end
end
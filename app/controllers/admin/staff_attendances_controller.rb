module Admin
  class StaffAttendancesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_attendance_permission!
    before_action :set_date, only: [:index, :mark_attendance, :save_attendance]

    def index
      @staff_members = StaffAssignment.active.includes(:user, :department).order(:position)
      @attendance_records = StaffAttendanceRecord.where(date: @date).index_by(&:staff_assignment_id)
      @statuses = StaffAttendanceStatus.all
    end

    def mark_attendance
      @staff_members = StaffAssignment.active.includes(:user, :department).order(:position)
      @attendance_records = StaffAttendanceRecord.where(date: @date).index_by(&:staff_assignment_id)
      @statuses = StaffAttendanceStatus.all
      render :index
    end

    def save_attendance
      params[:attendances]&.each do |staff_assignment_id, status_id|
        attendance = StaffAttendanceRecord.find_or_initialize_by(
          staff_assignment_id: staff_assignment_id,
          date: @date
        )
        attendance.staff_attendance_status_id = status_id  # Changed from status_id
        attendance.recorded_by = current_user
        attendance.check_in_time = params[:check_in_time][staff_assignment_id] if params[:check_in_time].present?
        attendance.check_out_time = params[:check_out_time][staff_assignment_id] if params[:check_out_time].present?
        attendance.notes = params[:notes][staff_assignment_id] if params[:notes].present?
        attendance.save
      end
      
      redirect_to admin_staff_attendances_path(date: @date), notice: 'Staff attendance was successfully recorded.'
    end

    def weekly_report
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @week_start = @date.beginning_of_week
      @week_end = @date.end_of_week
      @staff_members = StaffAssignment.active.includes(:user, :department).order(:position)
      @attendance_records = StaffAttendanceRecord.where(date: @week_start..@week_end)
    end

    def monthly_summary
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @staff_members = StaffAssignment.active.includes(:user, :department).order(:position)
      
      @staff_members.each do |staff|
        StaffAttendanceSummary.generate_for_month(staff, @date)
      end
      
      @summaries = StaffAttendanceSummary.where(
        staff_assignment_id: @staff_members.map(&:id),
        month: @date.month,
        year: @date.year
      ).includes(:staff_assignment)
    end

    private

    def ensure_attendance_permission!
      unless current_user.admin? || current_user.can_manage_staff_attendance?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access staff attendance.'
      end
    end

    def set_date
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
    end
  end
end
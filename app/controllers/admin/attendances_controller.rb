module Admin
  class AttendancesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_attendance_permission!
    before_action :set_school_class, only: [:index, :mark_attendance, :save_attendance]
    before_action :set_date, only: [:index, :mark_attendance, :save_attendance]

    def index
      if params[:class_id].blank?
        @school_classes = SchoolClass.all.order(:name)
        return render :select_class
      end
      
      @students = @school_class.students.order(:first_name)
      @attendance_records = AttendanceRecord.where(school_class_id: @school_class.id, date: @date)
                                            .index_by(&:student_id)
      @statuses = AttendanceStatus.all
    end

    def select_class
      @school_classes = SchoolClass.all.order(:name)
    end

    def mark_attendance
      @students = @school_class.students.order(:first_name)
      @attendance_records = AttendanceRecord.where(school_class_id: @school_class.id, date: @date)
                                            .index_by(&:student_id)
      @statuses = AttendanceStatus.all
      render :index
    end

    def save_attendance
      params[:attendances]&.each do |student_id, status_id|
        attendance = AttendanceRecord.find_or_initialize_by(
          student_id: student_id,
          school_class_id: @school_class.id,
          date: @date
        )
        attendance.attendance_status_id = status_id  # Changed from status_id
        attendance.user_id = current_user.id
        attendance.remarks = params[:remarks][student_id] if params[:remarks].present?
        attendance.save
      end
      
      # Update weekly summary
      update_weekly_summary(@school_class, @date)
      
      redirect_to admin_attendances_path(class_id: @school_class.id, date: @date), 
                  notice: 'Attendance was successfully recorded.'
    end

    def weekly_report
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @week_start = @date.beginning_of_week
      @week_end = @date.end_of_week
      
      if params[:class_id].present?
        @school_class = SchoolClass.find(params[:class_id])
        @students = @school_class.students.order(:first_name)
      else
        @students = Student.all.order(:first_name)
      end
      
      @attendance_records = AttendanceRecord.where(date: @week_start..@week_end)
                                            .includes(:student, :attendance_status)
      @statuses = AttendanceStatus.all
    end

    def student_report
      @student = Student.find(params[:student_id])
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @month = params[:month] ? Date.parse(params[:month]) : Date.today
      
      @attendances = AttendanceRecord.where(student_id: @student.id, date: @month.beginning_of_month..@month.end_of_month)
                                     .order(:date)
      
      @summary = {
        total_days: @attendances.count,
        present: @attendances.present.count,
        absent: @attendances.absent.count,
        late: @attendances.late.count,
        percentage: @attendances.count > 0 ? (@attendances.present.count.to_f / @attendances.count * 100).round(1) : 0
      }
    end

    private

    def ensure_attendance_permission!
      unless current_user.admin? || current_user.can_manage_attendance?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access attendance.'
      end
    end

    def set_school_class
      @school_class = SchoolClass.find(params[:class_id]) if params[:class_id].present?
    end

    def set_date
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
    end

    def update_weekly_summary(school_class, date)
      week_start = date.beginning_of_week
      students = school_class.students
      
      students.each do |student|
        attendances = AttendanceRecord.where(student_id: student.id, date: week_start..week_start.end_of_week)
        total_present = attendances.present.count
        total_absent = attendances.absent.count
        total_late = attendances.late.count
        total_days = attendances.count
        
        percentage = total_days > 0 ? (total_present.to_f / total_days * 100).round(2) : 0
        
        summary = WeeklyAttendanceSummary.find_or_initialize_by(
          student_id: student.id,
          week_starting: week_start
        )
        summary.update(
          total_present: total_present,
          total_absent: total_absent,
          total_late: total_late,
          attendance_percentage: percentage
        )
      end
    end
  end
end
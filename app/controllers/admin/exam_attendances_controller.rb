module Admin
  class ExamAttendancesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_exam_permission!
    before_action :set_exam_attendance, only: [:show, :edit, :update, :destroy]
    before_action :set_exam_schedule, only: [:new, :create, :batch_attendance]

    def index
      @exam_attendances = if current_user.admin?
                            ExamAttendance.includes(:student, :school_class, :subject, :exam_schedule).order(created_at: :desc)
                          else
                            ExamAttendance.accessible_by(current_user).includes(:student, :school_class, :subject, :exam_schedule).order(created_at: :desc)
                          end
      
      # Statistics
      @total_attendance = @exam_attendances.count
      @present_count = @exam_attendances.present.count
      @absent_count = @exam_attendances.absent.count
      @attendance_rate = @total_attendance > 0 ? (@present_count.to_f / @total_attendance * 100).round(1) : 0
      
      # Get exam schedules for the modal selector
      @exam_schedules_list = ExamSchedule.all.includes(:subject, :exam_type).order(start_time: :desc)
    end

    def show
    end

    def new
      # Get students for the selected exam schedule's class and subject
      @students = @exam_schedule.school_class.students.order(:first_name)
      @existing_attendances = ExamAttendance.where(exam_schedule_id: @exam_schedule.id).pluck(:student_id)
    end

    def create
      # Handle single attendance creation
      @exam_attendance = ExamAttendance.new(exam_attendance_params)
      @exam_attendance.school_class = @exam_schedule.school_class
      @exam_attendance.subject = @exam_schedule.subject
      
      if @exam_attendance.save
        redirect_to admin_exam_attendances_path, notice: 'Exam attendance was successfully recorded.'
      else
        @students = @exam_schedule.school_class.students.order(:first_name)
        @existing_attendances = ExamAttendance.where(exam_schedule_id: @exam_schedule.id).pluck(:student_id)
        render :new
      end
    end

    def edit
      @exam_schedule = @exam_attendance.exam_schedule
    end

    def update
      if @exam_attendance.update(exam_attendance_params)
        redirect_to admin_exam_attendances_path, notice: 'Exam attendance was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @exam_attendance.destroy
      redirect_to admin_exam_attendances_path, notice: 'Exam attendance was successfully deleted.'
    end

    def batch_attendance
      unless @exam_schedule
        redirect_to admin_exam_attendances_path, alert: 'Exam schedule not found.'
        return
      end
      
      # Get students for this class - handle case when no students exist
      @students = @exam_schedule.school_class.students.order(:first_name) if @exam_schedule.school_class
      @students ||= []
      
      @existing_attendances = ExamAttendance.where(exam_schedule_id: @exam_schedule.id).index_by(&:student_id)
      
      if request.post?
        # Process batch attendance update
        if params[:attendances].present?
          params[:attendances].each do |student_id, status|
            attendance = ExamAttendance.find_or_initialize_by(
              exam_schedule_id: @exam_schedule.id,
              student_id: student_id
            )
            attendance.school_class_id = @exam_schedule.school_class_id
            attendance.subject_id = @exam_schedule.subject_id
            attendance.status = status
            attendance.remarks = params[:remarks][student_id] if params[:remarks].present?
            attendance.save
          end
          
          redirect_to admin_exam_attendances_path, notice: 'Batch attendance was successfully recorded.'
        else
          redirect_to admin_exam_attendances_path, alert: 'No attendance data was submitted.'
        end
      end
    end

    def by_exam
      @exam_schedule = ExamSchedule.find(params[:exam_schedule_id])
      @attendances = ExamAttendance.where(exam_schedule_id: @exam_schedule.id).includes(:student)
      @present_count = @attendances.present.count
      @absent_count = @attendances.absent.count
      @attendance_rate = @attendances.count > 0 ? (@present_count.to_f / @attendances.count * 100).round(1) : 0
      
      respond_to do |format|
        format.html { render :by_exam }
        format.json { render json: { attendances: @attendances, summary: { present: @present_count, absent: @absent_count, rate: @attendance_rate } } }
      end
    end

    private

    def ensure_exam_permission!
      unless current_user.admin? || current_user.can_manage_exams?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access exam attendance.'
      end
    end

    def set_exam_attendance
      @exam_attendance = ExamAttendance.find(params[:id])
    end

    def set_exam_schedule
      @exam_schedule = ExamSchedule.find(params[:exam_schedule_id]) if params[:exam_schedule_id].present?
    end

    def exam_attendance_params
      params.require(:exam_attendance).permit(:student_id, :exam_schedule_id, :status, :remarks)
    end
  end
end
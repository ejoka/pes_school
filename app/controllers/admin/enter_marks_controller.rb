module Admin
  class EnterMarksController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_exam_permission!
    before_action :set_enter_mark, only: [:show, :edit, :update, :destroy]
    before_action :set_exam_attendance, only: [:new, :create, :batch_marks]

    def index
      @enter_marks = if current_user.admin?
                       EnterMark.includes(:student, :subject, :exam_attendance, :user).order(created_at: :desc)
                     else
                       EnterMark.accessible_by(current_user).includes(:student, :subject, :exam_attendance, :user).order(created_at: :desc)
                     end
      
      # Statistics
      @total_marks = @enter_marks.count
      @average_percentage = @enter_marks.average(:percentage).to_f.round(2)
      @pass_count = @enter_marks.select { |m| m.status == 'pass' }.count
      @fail_count = @enter_marks.select { |m| m.status == 'fail' }.count
      @pass_rate = @total_marks > 0 ? (@pass_count.to_f / @total_marks * 100).round(1) : 0
      
      # Group by exam attendance
      @exam_attendances_list = ExamAttendance.all.includes(:exam_schedule).order(created_at: :desc)
    end

    def show
    end

    def new
      @students = @exam_attendance.exam_schedule.school_class.students.order(:first_name)
      @existing_marks = EnterMark.where(exam_attendance_id: @exam_attendance.id).index_by(&:student_id)
    end

    def create
      @enter_mark = EnterMark.new(enter_mark_params)
      @enter_mark.user_id = current_user.id  # This now works with user_id
      @enter_mark.school_class = @exam_attendance.school_class
      @enter_mark.subject = @exam_attendance.subject
      
      if @enter_mark.save
        redirect_to admin_enter_marks_path, notice: 'Marks were successfully recorded.'
      else
        @students = @exam_attendance.exam_schedule.school_class.students.order(:first_name)
        @existing_marks = EnterMark.where(exam_attendance_id: @exam_attendance.id).index_by(&:student_id)
        render :new
      end
    end

    def edit
      @exam_attendance = @enter_mark.exam_attendance
    end

    def update
      if @enter_mark.update(enter_mark_params)
        redirect_to admin_enter_marks_path, notice: 'Marks were successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @enter_mark.destroy
      redirect_to admin_enter_marks_path, notice: 'Marks were successfully deleted.'
    end

    def batch_marks
      @students = @exam_attendance.exam_schedule.school_class.students.order(:first_name)
      @existing_marks = EnterMark.where(exam_attendance_id: @exam_attendance.id).index_by(&:student_id)
      @total_marks_possible = params[:total_marks] || 100
      
      if request.post?
        # Process batch marks entry
        total_marks = params[:total_marks].to_f
        
        params[:marks]&.each do |student_id, marks_data|
          marks_obtained = marks_data[:marks_obtained].to_f
          remarks = marks_data[:remarks]
          
          next if marks_obtained == 0 && !params[:marks][student_id][:marks_obtained].present?
          
          enter_mark = EnterMark.find_or_initialize_by(
            exam_attendance_id: @exam_attendance.id,
            student_id: student_id
          )
          enter_mark.school_class_id = @exam_attendance.school_class_id
          enter_mark.subject_id = @exam_attendance.subject_id
          enter_mark.marks_obtained = marks_obtained
          enter_mark.total_marks = total_marks
          enter_mark.remarks = remarks
          enter_mark.user_id = current_user.id
          enter_mark.save
        end
        
        redirect_to admin_enter_marks_path, notice: 'Batch marks were successfully recorded.'
      end
    end

    def by_exam
      @exam_attendance = ExamAttendance.find(params[:exam_attendance_id])
      @marks = EnterMark.where(exam_attendance_id: @exam_attendance.id).includes(:student)
      @present_count = @marks.count
      @average_mark = @marks.average(:marks_obtained).to_f.round(2)
      @average_percentage = @marks.average(:percentage).to_f.round(2)
      @pass_count = @marks.select { |m| m.status == 'pass' }.count
      
      respond_to do |format|
        format.html { render :by_exam }
        format.json { render json: { marks: @marks, summary: { average: @average_mark, percentage: @average_percentage, pass_count: @pass_count } } }
      end
    end

    private

    def ensure_exam_permission!
      unless current_user.admin? || current_user.can_manage_exams?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access exam marks.'
      end
    end

    def set_enter_mark
      @enter_mark = EnterMark.find(params[:id])
    end

    def set_exam_attendance
      @exam_attendance = ExamAttendance.find(params[:exam_attendance_id]) if params[:exam_attendance_id].present?
    end

    def enter_mark_params
      params.require(:enter_mark).permit(:student_id, :exam_attendance_id, :marks_obtained, :total_marks, :remarks)
    end
  end
end
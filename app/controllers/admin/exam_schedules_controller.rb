module Admin
  class ExamSchedulesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_exam_permission!
    before_action :set_exam_schedule, only: [:show, :edit, :update, :destroy]

    def index
      @exam_schedules = if current_user.admin?
                          ExamSchedule.includes(:subject, :school_class, :exam_type, :user).order(start_time: :asc)
                        else
                          ExamSchedule.accessible_by(current_user).includes(:subject, :school_class, :exam_type, :user).order(start_time: :asc)
                        end
      @upcoming_schedules = @exam_schedules.upcoming
      @ongoing_schedules = @exam_schedules.ongoing
      @past_schedules = @exam_schedules.past
    end

    def show
    end

    def new
      @exam_schedule = ExamSchedule.new
      @subjects = Subject.all.order(:name)
      @school_classes = SchoolClass.all.order(:name)
      @exam_types = ExamType.all.order(:name)
      @teachers = User.where(role: :user, professional_type: 'Teacher').or(User.where(role: :admin)).order(:first_name)
    end

    def create
      @exam_schedule = ExamSchedule.new(exam_schedule_params)
      
      if @exam_schedule.save
        redirect_to admin_exam_schedules_path, notice: 'Exam schedule was successfully created.'
      else
        load_form_data
        render :new
      end
    end

    def edit
      load_form_data
    end

    def update
      if @exam_schedule.update(exam_schedule_params)
        redirect_to admin_exam_schedules_path, notice: 'Exam schedule was successfully updated.'
      else
        load_form_data
        render :edit
      end
    end

    def destroy
      @exam_schedule.destroy
      redirect_to admin_exam_schedules_path, notice: 'Exam schedule was successfully deleted.'
    end

    private

    def ensure_exam_permission!
      unless current_user.admin? || current_user.can_manage_exams?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access exam schedules.'
      end
    end

    def set_exam_schedule
      @exam_schedule = ExamSchedule.find(params[:id])
    end

    def load_form_data
      @subjects = Subject.all.order(:name)
      @school_classes = SchoolClass.all.order(:name)
      @exam_types = ExamType.all.order(:name)
      @teachers = User.where(role: :user, professional_type: 'Teacher').or(User.where(role: :admin)).order(:first_name)
    end

    def exam_schedule_params
      params.require(:exam_schedule).permit(:subject_id, :school_class_id, :exam_type_id, :user_id, :start_time, :end_time, :venue, :description)
    end
  end
end
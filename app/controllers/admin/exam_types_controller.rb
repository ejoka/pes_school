module Admin
  class ExamTypesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_exam_permission!
    before_action :set_exam_type, only: [:show, :edit, :update, :destroy]

    def index
      @exam_types = if current_user.admin?
                      ExamType.ordered.all
                    else
                      ExamType.accessible_by(current_user).ordered
                    end
    end

    def show
    end

    def new
      @exam_type = ExamType.new
    end

    def create
      @exam_type = ExamType.new(exam_type_params)
      
      if @exam_type.save
        redirect_to admin_exam_types_path, notice: 'Exam type was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @exam_type.update(exam_type_params)
        redirect_to admin_exam_types_path, notice: 'Exam type was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @exam_type.destroy
      redirect_to admin_exam_types_path, notice: 'Exam type was successfully deleted.'
    end

    private

    def ensure_exam_permission!
      unless current_user.admin? || current_user.can_manage_exams?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access exam types.'
      end
    end

    def set_exam_type
      @exam_type = ExamType.find(params[:id])
    end

    def exam_type_params
      params.require(:exam_type).permit(:name, :average_pass_mark, :description)
    end
  end
end
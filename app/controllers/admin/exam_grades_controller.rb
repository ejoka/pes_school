module Admin
  class ExamGradesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_exam_permission!
    before_action :set_exam_grade, only: [:show, :edit, :update, :destroy]

    def index
      @exam_grades = if current_user.admin?
                       ExamGrade.ordered.all
                     else
                       ExamGrade.accessible_by(current_user).ordered
                     end
    end

    def show
    end

    def new
      @exam_grade = ExamGrade.new
    end

    def create
      @exam_grade = ExamGrade.new(exam_grade_params)
      
      if @exam_grade.save
        redirect_to admin_exam_grades_path, notice: 'Exam grade was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @exam_grade.update(exam_grade_params)
        redirect_to admin_exam_grades_path, notice: 'Exam grade was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @exam_grade.destroy
      redirect_to admin_exam_grades_path, notice: 'Exam grade was successfully deleted.'
    end

    private

    def ensure_exam_permission!
      unless current_user.admin? || current_user.can_manage_exams?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access exam grades.'
      end
    end

    def set_exam_grade
      @exam_grade = ExamGrade.find(params[:id])
    end

    def exam_grade_params
      params.require(:exam_grade).permit(:name, :percentage_from, :percentage_to, :description)
    end
  end
end
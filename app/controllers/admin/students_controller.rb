class Admin::StudentsController < ApplicationController
  before_action :ensure_authorized!
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.admin? || current_user.can_manage_students?(:view)
      @students = Student.all.includes(:school_class, :parent_info).order(created_at: :desc)
    else
      redirect_to dashboard_path, alert: 'You do not have permission to view students.'
    end
  end

  def show
    unless current_user.can_manage_students?(:view)
      redirect_to admin_students_path, alert: 'You do not have permission to view this student.'
    end
    @parent_info = @student.parent_info || @student.build_parent_info
  end

  def new
    unless current_user.can_manage_students?(:create)
      redirect_to admin_students_path, alert: 'You do not have permission to create students.'
    end
    @student = Student.new
    @student.build_parent_info
    @school_classes = SchoolClass.all.order(:name)
  end

  def create
    unless current_user.can_manage_students?(:create)
      redirect_to admin_students_path, alert: 'You do not have permission to create students.'
    end
    
    @student = Student.new(student_params)
    @student.user = current_user

    if @student.save
      redirect_to admin_students_path, notice: 'Student was successfully created.'
    else
      @school_classes = SchoolClass.all.order(:name)
      render :new
    end
  end

  def edit
    unless current_user.can_manage_students?(:edit)
      redirect_to admin_students_path, alert: 'You do not have permission to edit students.'
    end
    @parent_info = @student.parent_info || @student.build_parent_info
    @school_classes = SchoolClass.all.order(:name)
  end

  def update
    unless current_user.can_manage_students?(:edit)
      redirect_to admin_students_path, alert: 'You do not have permission to update students.'
    end
    
    if @student.update(student_params)
      redirect_to admin_students_path, notice: 'Student was successfully updated.'
    else
      @school_classes = SchoolClass.all.order(:name)
      @parent_info = @student.parent_info || @student.build_parent_info
      render :edit
    end
  end

  def destroy
    unless current_user.can_manage_students?(:delete)
      redirect_to admin_students_path, alert: 'You do not have permission to delete students.'
    end
    
    @student.destroy
    redirect_to admin_students_path, notice: 'Student was successfully deleted.'
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def ensure_authorized!
    unless current_user.admin? || current_user.can_manage_students?(:view)
      redirect_to root_path, alert: 'Access denied.'
    end
  end

  def student_params
    params.require(:student).permit(
      :first_name, :middle_name, :last_name, :date_of_birth, :gender,
      :religion, :academic_year, :admission_date, :student_address, :school_class_id,
      parent_info_attributes: [
        :id, :father_name, :father_occupation, :father_phone, :father_email,
        :mother_name, :mother_occupation, :mother_phone, :mother_email,
        :guardian_name, :guardian_occupation, :guardian_phone, :guardian_email
      ]
    )
  end
end
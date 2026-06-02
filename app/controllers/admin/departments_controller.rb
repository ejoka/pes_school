module Admin
  class DepartmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_staff_permission!
    before_action :set_department, only: [:show, :edit, :update, :destroy]

    def index
      @departments = if current_user.admin?
                       Department.ordered.all
                     else
                       Department.accessible_by(current_user).ordered
                     end
    end

    def show
      @staff_assignments = @department.staff_assignments.active.includes(:user)
    end

    def new
      @department = Department.new
      @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name)
    end

    def create
      @department = Department.new(department_params)
      if @department.save
        redirect_to admin_departments_path, notice: 'Department was successfully created.'
      else
        @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name)
        render :new
      end
    end

    def edit
      @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name)
    end

    def update
      if @department.update(department_params)
        redirect_to admin_departments_path, notice: 'Department was successfully updated.'
      else
        @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name)
        render :edit
      end
    end

    def destroy
      @department.destroy
      redirect_to admin_departments_path, notice: 'Department was successfully deleted.'
    end

    private

    def ensure_staff_permission!
      unless current_user.admin? || current_user.can_manage_staff?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access departments.'
      end
    end

    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:name, :code, :description, :hod_id)
    end
  end
end
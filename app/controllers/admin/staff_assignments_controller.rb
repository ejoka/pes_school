module Admin
  class StaffAssignmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_staff_permission!
    before_action :set_assignment, only: [:show, :edit, :update, :destroy]

    def index
      @assignments = if current_user.admin?
                       StaffAssignment.includes(:user, :department).order(created_at: :desc)
                     else
                       StaffAssignment.accessible_by(current_user).includes(:user, :department).order(created_at: :desc)
                     end
      
      # Ensure @assignments is always an array
      @assignments = @assignments.to_a
    end

    def show
      @payrolls = @assignment.payrolls.order(year: :desc, month: :desc).to_a
    end

    def new
      @assignment = StaffAssignment.new
      @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name).to_a
      @departments = Department.all.order(:name).to_a
    end

    def create
      @assignment = StaffAssignment.new(assignment_params)
      if @assignment.save
        redirect_to admin_staff_assignments_path, notice: 'Staff was successfully assigned.'
      else
        @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name).to_a
        @departments = Department.all.order(:name).to_a
        render :new
      end
    end

    def edit
      @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name).to_a
      @departments = Department.all.order(:name).to_a
    end

    def update
      if @assignment.update(assignment_params)
        redirect_to admin_staff_assignments_path, notice: 'Staff assignment was successfully updated.'
      else
        @users = User.where(role: :user).or(User.where(role: :admin)).order(:first_name).to_a
        @departments = Department.all.order(:name).to_a
        render :edit
      end
    end

    def destroy
      @assignment.destroy
      redirect_to admin_staff_assignments_path, notice: 'Staff assignment was successfully removed.'
    end

    private

    def ensure_staff_permission!
      unless current_user.admin? || current_user.can_manage_staff?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access staff assignments.'
      end
    end

    def set_assignment
      @assignment = StaffAssignment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_staff_assignments_path, alert: 'Staff assignment not found.'
    end

    def assignment_params
      params.require(:staff_assignment).permit(:user_id, :department_id, :position, :joined_date, :status)
    end
  end
end
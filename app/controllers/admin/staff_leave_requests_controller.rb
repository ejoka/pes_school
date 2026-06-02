module Admin
  class StaffLeaveRequestsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_attendance_permission!
    before_action :set_leave_request, only: [:show, :edit, :update, :destroy, :approve, :reject]

    def index
      @leave_requests = if current_user.admin?
                          StaffLeaveRequest.includes(staff_assignment: [:user, :department]).order(created_at: :desc)
                        else
                          StaffLeaveRequest.accessible_by(current_user).includes(staff_assignment: [:user, :department]).order(created_at: :desc)
                        end
    end

    def new
      @leave_request = StaffLeaveRequest.new
      @staff_members = StaffAssignment.active.includes(:user).order(:position)
    end

    def create
      @leave_request = StaffLeaveRequest.new(leave_request_params)
      if @leave_request.save
        redirect_to admin_staff_leave_requests_path, notice: 'Leave request was successfully created.'
      else
        @staff_members = StaffAssignment.active.includes(:user).order(:position)
        render :new
      end
    end

    def show
    end

    def edit
      @staff_members = StaffAssignment.active.includes(:user).order(:position)
    end

    def update
      if @leave_request.update(leave_request_params)
        redirect_to admin_staff_leave_requests_path, notice: 'Leave request was successfully updated.'
      else
        @staff_members = StaffAssignment.active.includes(:user).order(:position)
        render :edit
      end
    end

    def destroy
      @leave_request.destroy
      redirect_to admin_staff_leave_requests_path, notice: 'Leave request was successfully deleted.'
    end

    def approve
      if @leave_request.update(status: 'approved', user: current_user, approved_date: Date.today)
        redirect_to admin_staff_leave_requests_path, notice: 'Leave request was approved.'
      else
        redirect_to admin_staff_leave_requests_path, alert: 'Failed to approve leave request.'
      end
    end

    def reject
      if @leave_request.update(status: 'rejected', user: current_user, approved_date: Date.today)
        redirect_to admin_staff_leave_requests_path, notice: 'Leave request was rejected.'
      else
        redirect_to admin_staff_leave_requests_path, alert: 'Failed to reject leave request.'
      end
    end

    private

    def ensure_attendance_permission!
      unless current_user.admin? || current_user.can_manage_staff_attendance?(:edit)
        redirect_to dashboard_path, alert: 'You do not have permission to manage leave requests.'
      end
    end

    def set_leave_request
      @leave_request = StaffLeaveRequest.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_staff_leave_requests_path, alert: 'Leave request not found.'
    end

    def leave_request_params
      params.require(:staff_leave_request).permit(:staff_assignment_id, :leave_type, :start_date, :end_date, :reason, :status)
    end
  end
end
# module Admin
#   class StudentTransportAssignmentsController < ApplicationController
#     before_action :authenticate_user!
#     before_action :ensure_transport_permission!
#     before_action :set_assignment, only: [:show, :edit, :update, :destroy]

#     def index
#       @assignments = if current_user.admin?
#                        StudentTransportAssignment.includes(:student, :route).order(created_at: :desc)
#                      else
#                        StudentTransportAssignment.accessible_by(current_user).includes(:student, :route).order(created_at: :desc)
#                      end
      
#       # Statistics
#       @total_assignments = @assignments.count
#       @active_assignments = @assignments.active.count
#       @inactive_assignments = @assignments.where(status: 'inactive').count
#     end

#     def show
#     end

#     def new
#       @assignment = StudentTransportAssignment.new
#       @routes = Route.ordered.all  # Get all routes, no status filter
#       @eligible_students = Student.left_joins(student_fees: :fee_category)
#                                   .where(fee_categories: { name: 'Transport Fee' })
#                                   .where('student_fees.amount_paid >= student_fees.amount')
#                                   .where.not(id: StudentTransportAssignment.active.select(:student_id))
#                                   .distinct
#                                   .order(:first_name)
#     end

#     def create
#       @assignment = StudentTransportAssignment.new(assignment_params)
      
#       if @assignment.save
#         redirect_to admin_student_transport_assignments_path, notice: 'Student was successfully assigned to transport route.'
#       else
#         @routes = Route.active.includes(:school_bus_assignments).where(status: 'active').ordered
#         @eligible_students = Student.joins(:student_fees)
#                                     .where(student_fees: { 
#                                       fee_categories: { name: 'Transport Fee' },
#                                       is_paid: true
#                                     })
#                                     .where.not(id: StudentTransportAssignment.active.select(:student_id))
#                                     .distinct
#                                     .order(:first_name)
#         render :new
#       end
#     end

#     def edit
#       @routes = Route.active.includes(:school_bus_assignments).where(status: 'active').ordered
#       @eligible_students = Student.joins(:student_fees)
#                                   .where(student_fees: { 
#                                     fee_categories: { name: 'Transport Fee' },
#                                     is_paid: true
#                                   })
#                                   .or(Student.where(id: @assignment.student_id))
#                                   .distinct
#                                   .order(:first_name)
#     end

#     def update
#       if @assignment.update(assignment_params)
#         redirect_to admin_student_transport_assignments_path, notice: 'Student transport assignment was successfully updated.'
#       else
#         @routes = Route.active.includes(:school_bus_assignments).where(status: 'active').ordered
#         @eligible_students = Student.joins(:student_fees)
#                                     .where(student_fees: { 
#                                       fee_categories: { name: 'Transport Fee' },
#                                       is_paid: true
#                                     })
#                                     .or(Student.where(id: @assignment.student_id))
#                                     .distinct
#                                     .order(:first_name)
#         render :edit
#       end
#     end

#     def destroy
#       @assignment.destroy
#       redirect_to admin_student_transport_assignments_path, notice: 'Student transport assignment was successfully removed.'
#     end

#     private

#     def ensure_transport_permission!
#       unless current_user.admin? || current_user.can_manage_transport?(:view)
#         redirect_to dashboard_path, alert: 'You do not have permission to access student transport assignments.'
#       end
#     end

#     def set_assignment
#       @assignment = StudentTransportAssignment.find(params[:id])
#     end

#     def assignment_params
#       params.require(:student_transport_assignment).permit(:student_id, :route_id, :assigned_date, :status, :description)
#     end
#   end
# end

module Admin
  class StudentTransportAssignmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_transport_permission!
    before_action :set_assignment, only: [:show, :edit, :update, :destroy]

    def index
      @assignments = if current_user.admin?
                       StudentTransportAssignment.includes(:student, :route).order(created_at: :desc)
                     else
                       StudentTransportAssignment.accessible_by(current_user).includes(:student, :route).order(created_at: :desc)
                     end
      
      # Statistics
      @total_assignments = @assignments.count
      @active_assignments = @assignments.active.count
      @inactive_assignments = @assignments.where(status: 'inactive').count
    end

    def show
    end

    def new
      @assignment = StudentTransportAssignment.new
      @routes = Route.ordered.all
      
      # Get students with paid transport fee
      students_with_paid_transport = Student.joins(student_fees: :fee_category)
                                           .where(fee_categories: { name: 'Transport Fee' })
                                           .where('student_fees.amount_paid >= student_fees.amount')
                                           .distinct
      
      # Get already assigned students
      assigned_student_ids = StudentTransportAssignment.active.pluck(:student_id)
      
      # Final eligible students - use where.not instead of or
      @eligible_students = students_with_paid_transport.where.not(id: assigned_student_ids)
                                                       .order(:first_name)
      
      # Debug output
      Rails.logger.info "=== Student Transport Assignment Debug ==="
      Rails.logger.info "Students with paid transport fee: #{students_with_paid_transport.count}"
      Rails.logger.info "Already assigned students: #{assigned_student_ids.count}"
      Rails.logger.info "Eligible students: #{@eligible_students.count}"
    end

    def create
      @assignment = StudentTransportAssignment.new(assignment_params)
      
      if @assignment.save
        redirect_to admin_student_transport_assignments_path, notice: 'Student was successfully assigned to transport route.'
      else
        students_with_paid_transport = Student.joins(student_fees: :fee_category)
                                             .where(fee_categories: { name: 'Transport Fee' })
                                             .where('student_fees.amount_paid >= student_fees.amount')
                                             .distinct
        assigned_student_ids = StudentTransportAssignment.active.pluck(:student_id)
        @eligible_students = students_with_paid_transport.where.not(id: assigned_student_ids)
                                                         .order(:first_name)
        @routes = Route.ordered.all
        render :new
      end
    end

    def edit
      @routes = Route.ordered.all
      
      # Get students with paid transport fee
      students_with_paid_transport = Student.joins(student_fees: :fee_category)
                                          .where(fee_categories: { name: 'Transport Fee' })
                                          .where('student_fees.amount_paid >= student_fees.amount')
                                          .distinct
      
      # Get already assigned students excluding current assignment
      assigned_student_ids = StudentTransportAssignment.active
                                                      .where.not(id: @assignment.id)
                                                      .pluck(:student_id)
      
      # Combine query results
      eligible_ids = students_with_paid_transport.where.not(id: assigned_student_ids).pluck(:id)
      eligible_ids << @assignment.student_id if @assignment.student_id
      
      @eligible_students = Student.where(id: eligible_ids).order(:first_name)
    end

    def update
      if @assignment.update(assignment_params)
        redirect_to admin_student_transport_assignments_path, notice: 'Student transport assignment was successfully updated.'
      else
        @routes = Route.ordered.all
        students_with_paid_transport = Student.joins(student_fees: :fee_category)
                                             .where(fee_categories: { name: 'Transport Fee' })
                                             .where('student_fees.amount_paid >= student_fees.amount')
                                             .distinct
        assigned_student_ids = StudentTransportAssignment.active.where.not(id: @assignment.id).pluck(:student_id)
        current_student = Student.where(id: @assignment.student_id)
        @eligible_students = students_with_paid_transport.where.not(id: assigned_student_ids)
                                                         .or(current_student)
                                                         .distinct
                                                         .order(:first_name)
        render :edit
      end
    end

    def destroy
      @assignment.destroy
      redirect_to admin_student_transport_assignments_path, notice: 'Student transport assignment was successfully removed.'
    end

    private

    def ensure_transport_permission!
      unless current_user.admin? || current_user.can_manage_transport?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access student transport assignments.'
      end
    end

    def set_assignment
      @assignment = StudentTransportAssignment.find(params[:id])
    end

    def assignment_params
      params.require(:student_transport_assignment).permit(:student_id, :route_id, :assigned_date, :status, :description)
    end
  end
end
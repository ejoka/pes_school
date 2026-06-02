module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!
    before_action :set_user, only: [:show, :edit, :update, :destroy, :assign_resources, :save_resource_assignment]

    def index
      @users = User.all.order(created_at: :desc)
    end

    def show
      @assigned_categories = @user.assigned_categories
      @assigned_classes = @user.assigned_classes
      @assigned_subjects = @user.assigned_subjects
      @student_management = StudentManagement.default
      @has_student_management = @user.assigned_student_managements.include?(@student_management)
      @student_management_perms = if @has_student_management
        @user.permissions_for(@student_management)
      else
        {}
      end
      @fee_management = FeeManagement.default
      @has_fee_management = @user.assigned_fee_managements.include?(@fee_management)
      @fee_management_perms = if @has_fee_management
        @user.permissions_for(@fee_management)
      else
        {}
      end
    end

    def new
      @user = User.new
      @professional_types = User.unique_professional_types
    end

    def create
      @user = User.new(user_params)
      random_password = SecureRandom.hex(8)
      @user.password = random_password
      @user.password_confirmation = random_password
      
      if @user.save
        redirect_to admin_users_path, notice: "User #{@user.email} was successfully created. Temporary password: #{random_password}"
      else
        @professional_types = User.unique_professional_types
        render :new
      end
    end

    def edit
      @professional_types = User.unique_professional_types
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        @professional_types = User.unique_professional_types
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    end

    def assign_resources
      @categories = Category.all
      @classes = SchoolClass.all
      @subjects = Subject.all
      @student_management = StudentManagement.default
      @fee_management = FeeManagement.default
      @transport_management = TransportManagement.default
      @exam_management = ExamManagement.default
      @inventory_management = InventoryManagement.default
      @attendance_management = AttendanceManagement.default
      @resource_permissions = {}
      
      # Load existing permissions
      @user.user_resources.each do |ur|
        key = "#{ur.resource_type}_#{ur.resource_id}"
        @resource_permissions[key] = ur.permissions
      end
    end

    def save_resource_assignment
      # Clear existing assignments
      @user.user_resources.destroy_all

      if params[:resources].present?
        params[:resources].each do |resource_type, resources_data|
          if resource_type == 'Category'
            # Handle categories
            resources_data.each do |resource_id, permissions|
              next if resource_id.blank?
              @user.user_resources.create(
                resource_type: 'Category',
                resource_id: resource_id.to_i,
                permissions: {
                  can_view: permissions[:can_view] == '1',
                  can_create: permissions[:can_create] == '1',
                  can_edit: permissions[:can_edit] == '1',
                  can_delete: permissions[:can_delete] == '1'
                }
              )
            end
          elsif resource_type == 'SchoolClass'
            # Handle school classes
            resources_data.each do |resource_id, permissions|
              next if resource_id.blank?
              @user.user_resources.create(
                resource_type: 'SchoolClass',
                resource_id: resource_id.to_i,
                permissions: {
                  can_view: permissions[:can_view] == '1',
                  can_create: permissions[:can_create] == '1',
                  can_edit: permissions[:can_edit] == '1',
                  can_delete: permissions[:can_delete] == '1'
                }
              )
            end
          elsif resource_type == 'Subject'
            # Handle subjects
            resources_data.each do |resource_id, permissions|
              next if resource_id.blank?
              @user.user_resources.create(
                resource_type: 'Subject',
                resource_id: resource_id.to_i,
                permissions: {
                  can_view: permissions[:can_view] == '1',
                  can_create: permissions[:can_create] == '1',
                  can_edit: permissions[:can_edit] == '1',
                  can_delete: permissions[:can_delete] == '1'
                }
              )
            end
          elsif resource_type == 'StudentManagement'
            # Handle Student Management
            student_management = StudentManagement.default
            @user.user_resources.create(
              resource_type: 'StudentManagement',
              resource_id: student_management.id,
              permissions: {
                can_view: resources_data[:can_view] == '1',
                can_create: resources_data[:can_create] == '1',
                can_edit: resources_data[:can_edit] == '1',
                can_delete: resources_data[:can_delete] == '1'
              }
            )
          elsif resource_type == 'FeeManagement'
            # Handle Fee Management
            fee_management = FeeManagement.default
            @user.user_resources.create(
              resource_type: 'FeeManagement',
              resource_id: fee_management.id,
              permissions: {
                can_view: resources_data[:can_view] == '1',
                can_create: resources_data[:can_create] == '1',
                can_edit: resources_data[:can_edit] == '1',
                can_delete: resources_data[:can_delete] == '1'
              }
            )
          elsif resource_type == 'TransportManagement'
            # Handle Transport Management
            transport_management = TransportManagement.default
            @user.user_resources.create(
              resource_type: 'TransportManagement',
              resource_id: transport_management.id,
              permissions: {
                can_view: resources_data[:can_view] == '1',
                can_create: resources_data[:can_create] == '1',
                can_edit: resources_data[:can_edit] == '1',
                can_delete: resources_data[:can_delete] == '1'
              }
            )
          elsif resource_type == 'ExamManagement'
            # Handle Exam Management
            exam_management = ExamManagement.default
            @user.user_resources.create(
              resource_type: 'ExamManagement',
              resource_id: exam_management.id,
              permissions: {
                can_view: resources_data[:can_view] == '1',
                can_create: resources_data[:can_create] == '1',
                can_edit: resources_data[:can_edit] == '1',
                can_delete: resources_data[:can_delete] == '1'
              }
            )
          elsif resource_type == 'InventoryManagement'
            # Handle Inventory Management
            inventory_management = InventoryManagement.default
            @user.user_resources.create(
              resource_type: 'InventoryManagement',
              resource_id: inventory_management.id,
              permissions: {
                can_view: resources_data[:can_view] == '1',
                can_create: resources_data[:can_create] == '1',
                can_edit: resources_data[:can_edit] == '1',
                can_delete: resources_data[:can_delete] == '1'
              }
            )
          elsif resource_type == 'AttendanceManagement'
            # Handle Attendance Management
            attendance_management = AttendanceManagement.default
            @user.user_resources.create(
              resource_type: 'AttendanceManagement',
              resource_id: attendance_management.id,
              permissions: {
                can_view: resources_data[:can_view] == '1',
                can_create: resources_data[:can_create] == '1',
                can_edit: resources_data[:can_edit] == '1',
                can_delete: resources_data[:can_delete] == '1'
              }
            )
          end
        end
      end

      redirect_to admin_users_path, notice: 'Resources and permissions assigned successfully.'
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :middle_name, :last_name, :title, :phone_number, :email, :role, :professional_type)
    end
  end
end
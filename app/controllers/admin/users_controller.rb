class Admin::UsersController < ApplicationController
  before_action :ensure_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :assign_resources, :save_resource_assignment]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def show
    @assigned_categories = @user.assigned_categories
    @assigned_classes = @user.assigned_classes
    @assigned_subjects = @user.assigned_subjects
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
    @resource_permissions = {}
    
    # Load existing permissions
    @user.user_resources.each do |ur|
      key = "#{ur.resource_type}_#{ur.resource_id}"
      @resource_permissions[key] = ur.permissions
    end
  end

  def save_resource_assignment
    @user.user_resources.destroy_all

    if params[:resources]
      params[:resources].each do |resource_type, resources_data|
        resources_data.each do |resource_id, permissions|
          next if resource_id.blank?
          
          @user.user_resources.create(
            resource_type: resource_type,
            resource_id: resource_id,
            permissions: {
              can_view: permissions[:can_view] == '1',
              can_create: permissions[:can_create] == '1',
              can_edit: permissions[:can_edit] == '1',
              can_delete: permissions[:can_delete] == '1'
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
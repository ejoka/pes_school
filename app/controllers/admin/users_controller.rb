class Admin::UsersController < ApplicationController
  before_action :ensure_admin!
  before_action :set_user, only: [:edit, :update, :destroy, :assign_resources, :save_resource_assignment]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    random_password = SecureRandom.hex(8)
    @user.password = random_password
    @user.password_confirmation = random_password
    
    if @user.save
      redirect_to admin_users_path, notice: "User #{@user.email} was successfully created. Temporary password: #{random_password}"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: 'User was successfully updated.'
    else
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
  end

  def save_resource_assignment
    @user.user_resources.destroy_all

    if params[:resources]
      params[:resources].each do |resource_type, resource_ids|
        resource_ids.each do |resource_id|
          next if resource_id.blank?
          @user.user_resources.create(
            resource_type: resource_type,
            resource_id: resource_id
          )
        end
      end
    end

    redirect_to admin_users_path, notice: 'Resources assigned successfully.'
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :title, :phone_number, :email, :role)
  end
end
class AdminController < ApplicationController
  before_action :ensure_admin!

  def dashboard
    @users = User.all
    @categories = Category.all
    @classes = SchoolClass.all
    @subjects = Subject.all
  end

  def users
    @users = User.all
  end

  def edit_user
    @user = User.find(params[:id])
  end

  def update_user
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: 'User updated successfully.'
    else
      render :edit_user
    end
  end

  def delete_user
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: 'User deleted successfully.'
  end

  def assign_resources
    @user = User.find(params[:id])
    @categories = Category.all
    @classes = SchoolClass.all
    @subjects = Subject.all
  end

  def save_resource_assignment
    @user = User.find(params[:id])
    @user.user_resources.destroy_all

    if params[:resources]
      params[:resources].each do |resource_type, resource_ids|
        resource_ids.each do |resource_id|
          @user.user_resources.create(resource_type: resource_type, resource_id: resource_id)
        end
      end
    end

    redirect_to admin_users_path, notice: 'Resources assigned successfully.'
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def user_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :title, :phone_number, :email, :role)
  end
end
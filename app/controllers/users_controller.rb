class UsersController < ApplicationController
  before_action :ensure_user!

  def dashboard
    @accessible_categories = Category.accessible_by(current_user)
    @accessible_classes = SchoolClass.accessible_by(current_user)
    @accessible_subjects = Subject.accessible_by(current_user)
  end

  def profile
    @user = current_user
  end

  def update_profile
    if current_user.update(profile_params)
      redirect_to profile_path, notice: 'Profile updated successfully.'
    else
      render :profile
    end
  end

  private

  def ensure_user!
    redirect_to admin_dashboard_path if current_user.admin?
  end

  def profile_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :title, :phone_number, :email)
  end
end
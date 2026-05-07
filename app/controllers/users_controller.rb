class UsersController < ApplicationController
  before_action :redirect_admin_to_admin_panel, only: [:dashboard, :show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]

  def dashboard
    @accessible_categories = Category.accessible_by(current_user)
    @accessible_classes = SchoolClass.accessible_by(current_user)
    @accessible_subjects = Subject.accessible_by(current_user)
  end

  def show
    # This is the profile show action (user_profile#show)
    render :profile
  end

  def edit
    # This is the profile edit action (user_profile#edit)
    render :edit_profile
  end

  def update
    if @user.update(profile_params)
      redirect_to user_profile_path, notice: 'Profile was successfully updated.'
    else
      render :edit_profile
    end
  end

  private

  def redirect_admin_to_admin_panel
    if current_user.admin?
      redirect_to admin_dashboard_path and return
    end
  end

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :title, :phone_number)
  end
end
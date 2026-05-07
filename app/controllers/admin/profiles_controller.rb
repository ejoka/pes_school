class Admin::ProfilesController < ApplicationController
  before_action :ensure_admin!
  before_action :set_user

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to admin_admin_profile_path, notice: 'Profile was successfully updated.'
    else
      render :edit
    end
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :title, :phone_number)
  end
end
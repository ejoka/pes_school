class Admin::DashboardController < ApplicationController
  before_action :ensure_admin!

  def index
    @users = User.all
    @categories = Category.all
    @classes = SchoolClass.all
    @subjects = Subject.all
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end
end
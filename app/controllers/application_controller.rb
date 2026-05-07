class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :middle_name, :last_name, :title, :phone_number, :professional_type])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :middle_name, :last_name, :title, :phone_number, :professional_type])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      dashboard_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
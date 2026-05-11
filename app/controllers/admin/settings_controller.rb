module Admin
  class SettingsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin!

    def index
      @settings = Setting.all
    end

    def edit
      @setting = Setting.find(params[:id])
    end

    def update
      @setting = Setting.find(params[:id])
      if @setting.update(value: params[:setting][:value])
        redirect_to admin_settings_path, notice: 'Setting was successfully updated.'
      else
        render :edit
      end
    end

    def school_settings
      @settings = {
        school_name: Setting.find_or_create_by(key: 'school_name') { |s| s.value = 'School Management System' },
        school_address: Setting.find_or_create_by(key: 'school_address') { |s| s.value = '123 School Street, City, Country' },
        school_phone: Setting.find_or_create_by(key: 'school_phone') { |s| s.value = '+123 456 7890' },
        school_email: Setting.find_or_create_by(key: 'school_email') { |s| s.value = 'info@school.com' },
        school_website: Setting.find_or_create_by(key: 'school_website') { |s| s.value = 'www.school.com' },
        currency: Setting.find_or_create_by(key: 'currency') { |s| s.value = 'USD' },
        currency_symbol: Setting.find_or_create_by(key: 'currency_symbol') { |s| s.value = '$' },
        primary_color: Setting.find_or_create_by(key: 'primary_color') { |s| s.value = '#1e3a8a' },
        secondary_color: Setting.find_or_create_by(key: 'secondary_color') { |s| s.value = '#eab308' },
        accent_color: Setting.find_or_create_by(key: 'accent_color') { |s| s.value = '#ffffff' },
        logo_url: Setting.find_or_create_by(key: 'logo_url') { |s| s.value = '' },
        footer_text: Setting.find_or_create_by(key: 'footer_text') { |s| s.value = 'Thank you for your business.' },
        invoice_prefix: Setting.find_or_create_by(key: 'invoice_prefix') { |s| s.value = 'INV' },
        academic_year: Setting.find_or_create_by(key: 'academic_year') { |s| s.value = Date.today.year.to_s }
      }
    end

    def update_school_settings
      params[:settings].each do |key, value|
        setting = Setting.find_or_create_by(key: key)
        setting.update(value: value)
      end
      
      redirect_to admin_school_settings_path, notice: 'School settings were successfully updated.'
    end

    def color_settings
      @colors = {
        primary_color: Setting.find_or_create_by(key: 'primary_color') { |s| s.value = '#1e3a8a' },
        secondary_color: Setting.find_or_create_by(key: 'secondary_color') { |s| s.value = '#eab308' },
        accent_color: Setting.find_or_create_by(key: 'accent_color') { |s| s.value = '#ffffff' },
        sidebar_bg: Setting.find_or_create_by(key: 'sidebar_bg') { |s| s.value = '#1e3a8a' },
        header_bg: Setting.find_or_create_by(key: 'header_bg') { |s| s.value = '#ffffff' },
        button_bg: Setting.find_or_create_by(key: 'button_bg') { |s| s.value = '#eab308' },
        button_text: Setting.find_or_create_by(key: 'button_text') { |s| s.value = '#1e3a8a' }
      }
    end

    def update_color_settings
      params[:colors].each do |key, value|
        setting = Setting.find_or_create_by(key: key)
        setting.update(value: value)
      end
      
      # Update application CSS variables
      update_theme_variables
      
      redirect_to admin_color_settings_path, notice: 'Color settings were successfully updated.'
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
    end

    def update_theme_variables
      # This will be used to update CSS variables
      colors = {
        primary: Setting.find_by(key: 'primary_color')&.value || '#1e3a8a',
        secondary: Setting.find_by(key: 'secondary_color')&.value || '#eab308',
        accent: Setting.find_by(key: 'accent_color')&.value || '#ffffff'
      }
      
      # Store in session for current request
      session[:theme_colors] = colors
    end
  end
end
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
        sidebar_bg: Setting.find_or_create_by(key: 'sidebar_bg') { |s| s.value = '#1e3a8a' },
        header_bg: Setting.find_or_create_by(key: 'header_bg') { |s| s.value = '#ffffff' },
        button_bg: Setting.find_or_create_by(key: 'button_bg') { |s| s.value = '#eab308' },
        button_text: Setting.find_or_create_by(key: 'button_text') { |s| s.value = '#1e3a8a' },
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
      
      # Handle logo upload
      if params[:logo].present?
        logo_setting = Setting.find_or_create_by(key: 'logo')
        logo_setting.logo.attach(params[:logo])
      end
      
      # Handle favicon upload
      if params[:favicon].present?
        favicon_setting = Setting.find_or_create_by(key: 'favicon')
        favicon_setting.favicon.attach(params[:favicon])
      end
      
      # Regenerate theme after settings update
      regenerate_theme_variables
      
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
      
      # Clear Rails cache to force refresh
      Rails.cache.clear

      # Update timestamp to force cache refresh
      timestamp_setting = Setting.find_or_create_by(key: 'theme_last_updated')
      timestamp_setting.update(value: Time.now.to_i)
      
      # Touch the theme.css route to force refresh
      # This ensures the browser fetches a fresh copy
      flash[:notice] = 'Color settings were successfully updated. Refresh the page to see changes.'
      
      redirect_to admin_color_settings_path
    end

    private

    def ensure_admin!
      redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
    end

    def regenerate_theme_variables
      # Generate CSS file with current theme
      css_content = generate_theme_css
      
      # Write to a file that will be included in the layout
      File.write(Rails.root.join('app/assets/stylesheets/theme.css'), css_content)
      
      # Clear cache
      Rails.cache.clear
    end
    
    def generate_theme_css
      primary = Setting.get('primary_color', '#1e3a8a')
      secondary = Setting.get('secondary_color', '#eab308')
      accent = Setting.get('accent_color', '#ffffff')
      sidebar_bg = Setting.get('sidebar_bg', '#1e3a8a')
      header_bg = Setting.get('header_bg', '#ffffff')
      button_bg = Setting.get('button_bg', '#eab308')
      button_text = Setting.get('button_text', '#1e3a8a')
      
      <<-CSS
        :root {
          --primary-color: #{primary};
          --secondary-color: #{secondary};
          --accent-color: #{accent};
          --sidebar-bg: #{sidebar_bg};
          --header-bg: #{header_bg};
          --button-bg: #{button_bg};
          --button-text: #{button_text};
        }
        
        .bg-primary { background-color: var(--primary-color) !important; }
        .bg-secondary { background-color: var(--secondary-color) !important; }
        .text-primary { color: var(--primary-color) !important; }
        .text-secondary { color: var(--secondary-color) !important; }
        .border-primary { border-color: var(--primary-color) !important; }
        .border-secondary { border-color: var(--secondary-color) !important; }
        
        .btn-primary {
          background-color: var(--button-bg) !important;
          color: var(--button-text) !important;
        }
        .btn-primary:hover {
          opacity: 0.9;
        }
        
        .sidebar-bg { background-color: var(--sidebar-bg) !important; }
        .header-bg { background-color: var(--header-bg) !important; }
      CSS
    end
  end
end
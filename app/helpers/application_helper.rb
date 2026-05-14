module ApplicationHelper
  def format_currency(amount)
    return "0" if amount.nil?
    symbol = Setting.get('currency_symbol', '$')
    "#{symbol}#{number_with_delimiter(amount.to_i)}"
  end
  
  def currency_symbol
    Setting.get('currency_symbol', '$')
  end
  
  def currency_code
    Setting.get('currency', 'USD')
  end
  
  def school_logo
    logo_setting = Setting.find_by(key: 'logo')
    if logo_setting&.logo&.attached?
      image_tag logo_setting.logo, class: "h-12 w-auto object-contain", alt: "School Logo"
    else
      content_tag(:div, "SMS", class: "bg-yellow-500 text-blue-900 font-bold text-xl px-3 py-1 rounded")
    end
  end
  
  def school_favicon
    favicon_setting = Setting.find_by(key: 'favicon')
    if favicon_setting&.favicon&.attached?
      favicon_setting.favicon
    else
      nil
    end
  end
  
  def school_favicon_url
    favicon = school_favicon
    if favicon && favicon.attached?
      url_for(favicon)
    else
      nil
    end
  end
  
  def school_name
    Setting.get('school_name', 'School Management System')
  end
  
  def school_address
    Setting.get('school_address', '123 School Street, City, Country')
  end
  
  def school_phone
    Setting.get('school_phone', '+123 456 7890')
  end
  
  def school_email
    Setting.get('school_email', 'info@school.com')
  end
  
  def invoice_footer_text
    Setting.get('footer_text', 'Thank you for your business.')
  end

  def theme_css_path_with_cache_buster
    timestamp = Setting.get('theme_last_updated', Time.now.to_i)
    "#{theme_css_path}?v=#{timestamp}"
  end
end
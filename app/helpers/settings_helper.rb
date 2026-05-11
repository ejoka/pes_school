module SettingsHelper
  def school_setting(key, default = '')
    setting = Setting.find_by(key: key)
    setting ? setting.value : default
  end
  
  def currency_symbol
    school_setting('currency_symbol', '$')
  end
  
  def formatted_currency(amount)
    "#{currency_symbol}#{number_with_delimiter(amount.to_i)}"
  end
  
  def school_name
    school_setting('school_name', 'School Management System')
  end
  
  def school_address
    school_setting('school_address', '123 School Street, City, Country')
  end
  
  def school_phone
    school_setting('school_phone', '+123 456 7890')
  end
  
  def school_email
    school_setting('school_email', 'info@school.com')
  end
  
  def invoice_footer_text
    school_setting('footer_text', 'Thank you for your business.')
  end
  
  def invoice_prefix
    school_setting('invoice_prefix', 'INV')
  end
  
  def theme_color(key)
    school_setting(key, '#1e3a8a')
  end
  
  def primary_color
    theme_color('primary_color')
  end
  
  def secondary_color
    theme_color('secondary_color')
  end
  
  def accent_color
    theme_color('accent_color')
  end
end
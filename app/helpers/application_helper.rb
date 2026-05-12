module ApplicationHelper
  def format_currency(amount)
    return "0" if amount.nil?
    symbol = Setting.get('currency_symbol', '$')
    "#{symbol} #{number_with_delimiter(amount.to_i)}"
  end
  
  def school_logo
    logo_setting = Setting.find_by(key: 'logo')
    if logo_setting&.logo&.attached?
      image_tag logo_setting.logo, class: "h-12 w-auto object-contain", alt: "School Logo"
    else
      content_tag(:div, "SMS", class: "bg-yellow-500 text-blue-900 font-bold text-xl px-3 py-1 rounded")
    end
  end
  
  def school_name
    Setting.get('school_name', 'School Management System')
  end
end
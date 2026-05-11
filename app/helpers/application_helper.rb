module ApplicationHelper
  def theme_styles
    content_tag(:style, <<-CSS.strip_heredoc)
      :root {
        --primary-color: #{primary_color};
        --secondary-color: #{secondary_color};
        --accent-color: #{accent_color};
        --sidebar-bg: #{school_setting('sidebar_bg', '#1e3a8a')};
        --header-bg: #{school_setting('header_bg', '#ffffff')};
        --button-bg: #{school_setting('button_bg', '#eab308')};
        --button-text: #{school_setting('button_text', '#1e3a8a')};
      }
      
      .bg-primary { background-color: var(--primary-color); }
      .bg-secondary { background-color: var(--secondary-color); }
      .text-primary { color: var(--primary-color); }
      .text-secondary { color: var(--secondary-color); }
      .btn-primary {
        background-color: var(--button-bg);
        color: var(--button-text);
      }
    CSS
  end
end
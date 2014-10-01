module ApplicationHelper

  def body_attributes popup_window=nil, dashboard=nil
    action     = params[:action]
    controller = params[:controller]
    {
      class: ["main", action, controller].join(" ")
    }
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = Settings.app.name
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # match rails alerts to bootstrap classes
  def flash_class(level)
    case level.to_sym
    when :success then "alert-success alert-dismissable"
    when :notice then "alert-info alert-dismissable"
    when :alert then "alert-warning alert-dismissable"
    when :error then "alert-danger"
    end
  end

  def embedded_svg(filename, options={})
    file = File.read(Rails.root.join('app', 'assets', 'images', filename))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css 'svg'
    if options[:class].present?
      svg['class'] = options[:class]
    end
    if options[:size].present?
      current_height = svg['height'].to_f
      svg['width'] = options[:size].to_s
      svg['height'] = options[:size].to_s
      gee = svg.at_css 'g'
      gee['transform'] = "scale(#{options[:size]/current_height})"
      svg['viewbox'] = "0 0 #{options[:size]} #{options[:size]}"
    end
    doc.to_html.html_safe
  end
end

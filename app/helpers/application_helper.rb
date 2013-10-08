module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title.to_s }
  end

  def yield_or_default(section, default='')
    content_for?(section) ? content_for(section) : default
  end

  def nav_link(link_text, link_path, html_options={})
    class_name = if current_page?(link_path) then 'active' else '' end

    content_tag(:li, class: class_name) do
      link_to link_text, link_path, html_options
    end
  end
end

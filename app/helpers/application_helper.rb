module ApplicationHelper
  def full_title(page_title = "")
    base_title = "Packs"

    if page_title.present?
      "#{page_title} | #{base_title}"
    else
      base_title
    end
  end
end

module ApplicationHelper
  include Pagy::Frontend
  def full_title(page_title = "")
    base_title = "Packs"

    if page_title.present?
      "#{page_title} | #{base_title}"
    else
      base_title
    end
  end

  def pagination(obj)
    raw(pagy_bootstrap_nav(obj)) if obj.pages > 1
  end
end

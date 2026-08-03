module ApplicationHelper
  # Reads an SVG from app/assets/images and inlines its markup, so Grover's
  # headless-browser PDF rendering doesn't need a network round trip to fetch it.
  def inline_svg(filename)
    Rails.root.join("app", "assets", "images", filename).read.html_safe
  end

  def robots_meta_tag
    content = if Rails.env.production? && current_screener.blank?
      "index, follow"
    else
      "nofollow, noindex, noarchive"
    end
    tag("meta", name: "robots", content: content)
  end

  # From https://github.com/rwz/nestive/blob/master/lib/nestive/layout_helper.rb
  def extends(layout, &block)
    # Make sure it's a string
    layout = layout.to_s

    # If there's no directory component, presume a plain layout name
    layout = "layouts/#{layout}" unless layout.include?("/")

    # Capture the content to be placed inside the extended layout
    @view_flow.get(:layout).replace(capture(&block) || "")

    render template: layout
  end
end

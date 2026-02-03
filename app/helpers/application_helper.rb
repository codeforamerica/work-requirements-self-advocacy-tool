module ApplicationHelper
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

  def link_to_spanish(additional_attributes = {})
    link_to_locale("es", "Translate Español", additional_attributes)
  end

  def link_to_english(additional_attributes = {})
    link_to_locale("en", "Translate English", additional_attributes)
  end

  def link_to_locale(locale, label, additional_attributes = {})
    link_to(label,
      {locale: locale, params: request.query_parameters},
      lang: locale,
      id: "locale_switcher_#{locale}",
      **additional_attributes).html_safe
  end
end

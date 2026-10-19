class GetBenefitsHelpFormBuilder < Cfa::Styleguide::CfaFormBuilder
  # USWDS "memorable date" pattern: a month select plus day and year text inputs.
  # https://designsystem.digital.gov/patterns/create-a-user-profile/date-of-birth/
  def cfa_memorable_date(method, label_text, help_text: nil)
    describedby = [
      (help_text_id(method) if help_text),
      (error_label(method) if object.errors[method].any?)
    ].compact.join(" ").presence
    fieldset_tag = @template.tag(:fieldset, {class: "form-group memorable-date#{error_state(object, method)}", "aria-describedby": describedby}, true)

    month_options = @template.options_for_select(
      I18n.t("date.month_names").compact.each_with_index.map { |name, i| [name, i + 1] },
      object.public_send(subfield_name(method, "month")).to_i
    )
    month_select = @template.select_tag(
      "#{object_name}[#{subfield_name(method, "month")}]",
      month_options,
      id: sanitized_id(method, "month"),
      class: "select__element",
      prompt: I18n.t("general.select"),
      autocomplete: "bday-month"
    )

    <<~HTML.html_safe
      #{fieldset_tag}
        #{fieldset_label_contents(label_text: label_text, help_text: help_text, method: method)}
        <div class="memorable-date__fields">
          <div class="memorable-date__month">
            <label for="#{sanitized_id(method, "month")}" class="memorable-date__label">#{I18n.t("honeycrisp.month")}</label>
            <div class="select">#{month_select}</div>
          </div>
          #{memorable_date_text_field(method, "day", maxlength: 2, autocomplete: "bday-day")}
          #{memorable_date_text_field(method, "year", maxlength: 4, autocomplete: "bday-year")}
        </div>
        #{errors_for(object, method)}
      </fieldset>
    HTML
  end

  private

  def memorable_date_text_field(method, position, maxlength:, autocomplete:)
    field = text_field(
      subfield_name(method, position),
      id: sanitized_id(method, position),
      class: "text-input",
      inputmode: "numeric",
      maxlength: maxlength,
      autocomplete: autocomplete
    )

    <<~HTML
      <div class="memorable-date__#{position}">
        <label for="#{sanitized_id(method, position)}" class="memorable-date__label">#{I18n.t("honeycrisp.#{position}")}</label>
        #{field}
      </div>
    HTML
  end
end

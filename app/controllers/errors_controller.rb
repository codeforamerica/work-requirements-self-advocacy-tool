class ErrorsController < ApplicationController
  layout "error_page"

  # The catch-all route matches any unmatched path, including ones with a non-html
  # extension (e.g. a bot probing for "/foo.css"). Rails derives the response format
  # from that extension, and we only have html templates, so without this the format
  # mismatch raises ActionView::MissingTemplate instead of rendering a clean 404/etc.
  before_action { request.format = :html }

  def bad_request
    render status: :bad_request
  end

  def not_found
    render status: :not_found
  end

  def internal_server_error
    status = request.env["action_dispatch.exception"] ? :internal_server_error : :ok
    render status: status
  end

  private

  def switch_locale(&action)
    locale = params[:locale]
    locale = screener_locale || I18n.default_locale unless I18n.available_locales.map(&:to_s).include?(locale)
    I18n.with_locale(locale, &action)
  end

  def screener_locale
    current_screener&.locale
  rescue ActiveRecord::StatementInvalid, ActiveRecord::ConnectionNotEstablished
    nil
  end

  def set_screener_current_step_and_locale
    # intentionally left empty
    # params[:locale] is nil which would overwrite the screener's locale
  end
end

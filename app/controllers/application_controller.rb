class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def navigation_class
    "Navigation::#{current_screener.class.name}Navigation".constantize
  end
  helper_method :navigation_class
end

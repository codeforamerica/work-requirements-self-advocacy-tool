class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def navigation_class
    Navigation::ScreenerNavigation
  end
  helper_method :navigation_class
end

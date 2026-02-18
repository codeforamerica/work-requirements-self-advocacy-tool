class LandingPageController < ApplicationController
  layout "application"

  def index
  end

  def create_screener
    screener = Screener.create
    session[:screener_id] = screener.id
    redirect_to navigation_class.first.to_path_helper
  end
end

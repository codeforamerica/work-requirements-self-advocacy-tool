class LandingPageController < ApplicationController
  layout "application"

  def index
  end

  def create_screener
    Screener.create
    redirect_to navigation_class.first.to_path_helper
  end

end

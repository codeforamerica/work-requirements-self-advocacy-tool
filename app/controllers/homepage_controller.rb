class HomepageController < ApplicationController
  layout "application"

  def index
  end

  def create_screener
    screener = Screener.create(visitor_id: cookies.encrypted[:visitor_id])
    sign_in screener
    redirect_to navigation_class.first.to_path_helper
  end
end

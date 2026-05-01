class HomepageController < ApplicationController
  layout "application"

  def index
  end

  def create_screener
    screener = Screener.create(visitor_id: cookies.encrypted[:visitor_id], source: session[:source])
    sign_in screener
    redirect_to navigation_class.first.to_path_helper
  end

  def redirect_without_source
    redirect_to "/#{params[:base_path]}?source=#{params[:intended_source]}"
  end
end

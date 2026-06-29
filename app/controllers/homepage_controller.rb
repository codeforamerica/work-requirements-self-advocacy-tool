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
    path = params[:base_path].present? ? "/#{CGI.escape(params[:base_path])}" : "/"
    redirect_to "#{path}?source=#{CGI.escape(params[:intended_source].to_s)}"
  end
end

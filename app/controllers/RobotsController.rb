class RobotsController < ApplicationController
  PRODUCTION_HOSTS = [
    "www.getbenefitshelp.org",
    "getbenefitshelp.org"
  ].freeze

  def show
    if production_site?
      render plain: <<~TXT
        User-agent: *
        Allow: /
        Sitemap: https://getbenefitshelp.org/sitemap.xml
      TXT
    else
      render plain: <<~TXT
        User-agent: *
        Disallow: /
      TXT
    end
  end

  private

  def production_site?
    Rails.env.production? && PRODUCTION_HOSTS.include?(request.host)
  end
end

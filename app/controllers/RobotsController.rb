class RobotsController < ApplicationController
  def show
    if Rails.env.production?
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
end

# Propshaft writes a .manifest.json file listing every digested asset filename.
# Exposing it publicly lets attackers enumerate the full asset inventory and identify
# library versions for CVE-based attacks. Block it before static file serving kicks in.
module Middleware
  class BlockAssetManifest
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"].end_with?("/.manifest.json")
        [404, {"Content-Type" => "text/plain", "X-Content-Type-Options" => "nosniff"}, ["Not Found"]]
      else
        @app.call(env)
      end
    end
  end
end

Rails.application.config.middleware.insert_before ActionDispatch::Static, Middleware::BlockAssetManifest

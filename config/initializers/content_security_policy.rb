# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self, "https://cdn.mxpnl.com", "https://app.intercom.io", "https://widget.intercom.io", "https://js.intercomcdn.com"
    policy.style_src :self, "https://fonts.googleapis.com", "'unsafe-inline'"
    policy.font_src :self, "https://fonts.gstatic.com", "https://js.intercomcdn.com", "https://fonts.intercomcdn.com"
    policy.img_src :self, :data, :blob, "https://js.intercomcdn.com", "https://static.intercomassets.com", "https://downloads.intercomcdn.com", "https://uploads.intercomusercontent.com", "https://gifs.intercomcdn.com", "https://video-messages.intercomcdn.com", "https://messenger-apps.intercom.io"
    policy.connect_src :self, "https://api-js.mixpanel.com", "https://via.intercom.io", "https://api.intercom.io", "https://api-iam.intercom.io", "https://api-ping.intercom.io", "https://*.intercom-messenger.com", "wss://*.intercom-messenger.com", "https://nexus-websocket-a.intercom.io", "wss://nexus-websocket-a.intercom.io", "https://nexus-websocket-b.intercom.io", "wss://nexus-websocket-b.intercom.io", "https://uploads.intercomcdn.com", "https://uploads.intercomusercontent.com"
    policy.frame_src "https://intercom-sheets.com", "https://www.intercom-reporting.com"
    policy.media_src "https://js.intercomcdn.com", "https://downloads.intercomcdn.com"
    policy.object_src :none
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :self
    policy.directives["report-to"] = ["csp-endpoint"]
  end

  # The nonce must stay constant for the life of a session, not vary per request.
  # Turbo Drive swaps the <body> in place for plain link navigations (e.g. the
  # "Back" link in layouts/question.html.erb) without a full page load, so the
  # browser keeps enforcing whatever CSP nonce was set on the last full navigation.
  # A fresh per-request nonce would mismatch and silently block inline scripts/
  # styles delivered by those swapped-in responses.
  #
  # request.session.id isn't usable here: this app uses the default cookie_store,
  # which has no persistent server-side session id, so .id is effectively
  # regenerated per request. Stash our own value in the session data instead,
  # which does round-trip via the encrypted cookie.
  config.content_security_policy_nonce_generator = ->(request) { request.session[:_csp_nonce] ||= SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end

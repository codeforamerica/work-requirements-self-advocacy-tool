# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self, "https://cdn.mxpnl.com"
    policy.style_src :self, "https://fonts.googleapis.com"
    policy.font_src :self, "https://fonts.gstatic.com"
    policy.img_src :self, :data
    policy.connect_src :self, "https://api-js.mixpanel.com"
    policy.object_src :none
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :self

    # report-uri is the legacy fallback for browsers without Reporting API support.
    # report-to (paired with the Reporting-Endpoints header, see application.rb) is the
    # current standard. Rails' DSL has no report_to method, so set the directive directly
    # on the underlying hash that `directives` exposes.
    policy.report_uri "/csp_reports"
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
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end

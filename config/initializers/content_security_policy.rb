# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src  :self, "https://cdn.mxpnl.com"
    policy.style_src   :self, "https://fonts.googleapis.com"
    policy.font_src    :self, "https://fonts.gstatic.com"
    policy.img_src     :self, :data
    policy.connect_src :self, "https://api-js.mixpanel.com"
    policy.object_src  :none
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :self
  end

  # The nonce must stay constant for the life of a session, not vary per request.
  # Turbo Drive swaps the <body> in place for plain link navigations (e.g. the
  # "Back" link in layouts/question.html.erb) without a full page load, so the
  # browser keeps enforcing whatever CSP nonce was set on the last full navigation.
  # A fresh per-request nonce would mismatch and silently block inline scripts/
  # styles delivered by those swapped-in responses.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src style-src)
end

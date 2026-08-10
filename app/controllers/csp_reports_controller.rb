class CspReportsController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.warn("CSP violation report: #{request.body.read}")
    head :no_content
  end
end

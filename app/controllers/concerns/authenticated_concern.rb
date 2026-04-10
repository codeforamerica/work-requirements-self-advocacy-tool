module AuthenticatedConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_current_screener
  end

  private

  def require_current_screener
    redirect_to root_path if current_screener.blank?
  end
end

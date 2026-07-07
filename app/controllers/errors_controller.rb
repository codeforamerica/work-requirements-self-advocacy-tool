class ErrorsController < ApplicationController
  layout "error_page"

  def bad_request
    render status: :bad_request
  end

  def not_found
    render status: :not_found
  end

  def internal_server_error
    status = request.env["action_dispatch.exception"] ? :internal_server_error : :ok
    render status: status
  end
end

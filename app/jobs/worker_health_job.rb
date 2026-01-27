class WorkerHealthJob < ApplicationJob
  queue_as :default

  def perform
    log_message = "Worker health job performed"
    puts log_message
    logger.info log_message
  end
end

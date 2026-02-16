# Shared concern for job interruption support
# Provides methods to check for interruption signals and handle graceful shutdowns
module Interruptible
  extend ActiveSupport::Concern

  # Check if an interruption has been requested for this job
  # This can be triggered by:
  # 1. Setting a flag in Redis/cache
  # 2. External signal (for testing/demos)
  def check_interruption_flag
    # Check Redis for interruption flag
    flag_key = "interrupt:#{job_id}"

    if Rails.cache.read(flag_key)
      Rails.logger.info "[#{self.class.name}] Interruption flag detected, raising SIGTERM"
      Rails.cache.delete(flag_key)

      # Raise SignalException to trigger graceful shutdown
      # This mimics receiving a SIGTERM signal
      raise SignalException.new("TERM")
    end
  end

  # Set an interruption flag for this job
  # Useful for testing and controlled demos
  def request_interruption!
    flag_key = "interrupt:#{job_id}"
    Rails.cache.write(flag_key, true, expires_in: 1.hour)
    Rails.logger.info "[#{self.class.name}] Interruption requested for job #{job_id}"
  end

  # Get the current job ID
  # Works with both ActiveJob and Sidekiq
  def job_id
    return provider_job_id if respond_to?(:provider_job_id) && provider_job_id.present?
    return jid if respond_to?(:jid) && jid.present?
    "unknown"
  end

  class_methods do
    # Request interruption for a specific job by ID
    def request_interruption_for(job_id)
      flag_key = "interrupt:#{job_id}"
      Rails.cache.write(flag_key, true, expires_in: 1.hour)
      Rails.logger.info "[#{name}] Interruption requested for job #{job_id}"
    end
  end
end

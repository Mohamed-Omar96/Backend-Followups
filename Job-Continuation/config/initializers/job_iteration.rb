# Configure job-iteration gem
# The gem uses sensible defaults and integrates automatically with ActiveJob

# Configure Redis for cursor storage (optional, uses Sidekiq redis by default)
if defined?(JobIteration)
  # The gem will use Sidekiq's Redis configuration automatically
  # No additional configuration needed for basic usage

  # Add logging for job iteration events (optional)
  ActiveSupport::Notifications.subscribe("interrupted.iteration") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.info "Job interrupted: #{event.payload[:job_class]} at cursor #{event.payload[:cursor]}"
  end

  ActiveSupport::Notifications.subscribe("completed.iteration") do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.info "Job completed: #{event.payload[:job_class]} after #{event.payload[:executions]} executions"
  end
end

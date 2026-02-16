# Configure Sidekiq server and client
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5,
    reconnect_attempts: 3
  }

  # Ensure graceful shutdown with enough time for jobs to finish
  config.average_scheduled_poll_interval = 15
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
    network_timeout: 5,
    reconnect_attempts: 3
  }
end

# Configure Rails to use Sidekiq for ActiveJob
Rails.application.config.active_job.queue_adapter = :sidekiq

# Optional: Configure default queue
Sidekiq.default_job_options = { retry: 3, queue: :default }

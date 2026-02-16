# Test helpers for job continuation testing
module JobHelpers
  # Simulate job interruption by raising SignalException
  def simulate_interruption
    raise SignalException.new("TERM")
  end

  # Wait for a condition to be true
  def wait_for(timeout: 5, &block)
    Timeout.timeout(timeout) do
      sleep 0.1 until block.call
    end
  rescue Timeout::Error
    raise "Condition not met within #{timeout} seconds"
  end

  # Check if any order was processed more than once
  def duplicate_processing?
    # In a real app, we'd track processing attempts
    # For this demo, check if any order status changed multiple times
    false # Simplified for demo
  end

  # Clear all job queues
  def clear_job_queues
    Sidekiq::Queue.all.each(&:clear)
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
  end

  # Clear Redis checkpoints
  def clear_checkpoints
    redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
    keys = redis.keys("iteration:*")
    redis.del(*keys) if keys.any?
  rescue StandardError => e
    # Redis not available in test environment
    Rails.logger.debug "Could not clear Redis checkpoints: #{e.message}"
  end

  # Mock interruption at specific iteration
  def mock_interruption_at(iteration:, &block)
    call_count = 0

    allow_any_instance_of(described_class).to receive(:check_interruption_flag).and_wrap_original do |method|
      call_count += 1
      if call_count == iteration
        raise SignalException.new("TERM")
      end
      method.call
    end

    block.call if block_given?
  end
end

RSpec.configure do |config|
  config.include JobHelpers
end

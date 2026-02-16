# job-iteration example - Simple enumerator pattern
# Demonstrates automatic checkpoint and resume flow with enumerator API
module JobIteration
  class ProcessOrdersIterationJob < ApplicationJob
    include ::JobIteration::Iteration
    include Interruptible

    queue_as :default

    # Called on job start and each resume
    # Must return an enumerator that can resume from 'cursor'
    def build_enumerator(cursor:)
      Rails.logger.info "=" * 80
      Rails.logger.info "Building enumerator for ProcessOrdersIterationJob"
      Rails.logger.info "Resuming from cursor: #{cursor || 'beginning'}"
      Rails.logger.info "=" * 80

      # Use the built-in ActiveRecord enumerator helper
      # This automatically handles cursor-based resumption and ordering by primary key
      enumerator_builder.active_record_on_records(
        Order.pending,  # No explicit ORDER BY needed - handled by cursor mechanism
        cursor: cursor  # Last processed record ID (or nil for start)
      )
    end

    # Called once per item from the enumerator
    # Checkpoint is saved automatically after this method returns
    def each_iteration(order)
      check_interruption_flag

      # Process the order
      OrderProcessor.new(order).process!

      # Log progress periodically
      if order.id % 10 == 0
        processed_count = Order.processed.count
        total_count = Order.count
        Rails.logger.info "Progress: #{processed_count}/#{total_count} orders processed"
      end

      # No manual checkpoint needed - automatic!
    end

    # Called once after all iterations complete successfully
    def on_complete
      total_processed = Order.processed.count

      Rails.logger.info "=" * 80
      Rails.logger.info "All #{total_processed} orders processed successfully!"
      Rails.logger.info "Job completed at #{Time.current}"
      Rails.logger.info "=" * 80
    end

    # Called if job times out or is interrupted
    def on_shutdown
      cursor = cursor_position
      Rails.logger.info "Job interrupted, checkpoint saved at cursor: #{cursor}"
    end
  end
end

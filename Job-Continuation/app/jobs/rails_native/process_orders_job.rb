# Rails 8 Native job continuation example - Simple linear processing
# Demonstrates basic checkpoint and resume flow with step-based API
module RailsNative
  class ProcessOrdersJob < ApplicationJob
    include ActiveJob::Continuable
    include Interruptible

    queue_as :default

    def perform
      Rails.logger.info "=" * 80
      Rails.logger.info "Starting ProcessOrdersJob (Rails 8 Native)"
      Rails.logger.info "=" * 80

      # Count total pending orders for logging
      total_orders = Order.pending.count
      Rails.logger.info "Found #{total_orders} pending orders to process"

      # Step: Process each order with checkpoints
      step :process_orders do |step|
        processed_count = 0

        # Use find_each with cursor for efficient batch processing
        # The cursor is the ID of the last processed record
        Order.pending.find_each(start: step.cursor) do |order|
          # Check for interruption signal (demo helper)
          check_interruption_flag

          # Process the order
          OrderProcessor.new(order).process!
          processed_count += 1

          # Save checkpoint with current order's ID
          # On resume, find_each will start from this ID + 1
          step.advance! from: order.id

          # Log progress every 10 orders
          if processed_count % 10 == 0
            Rails.logger.info "Progress: #{processed_count} orders processed (last ID: #{order.id})"
          end
        end

        Rails.logger.info "Processed #{processed_count} orders in this run"
      end

      Rails.logger.info "=" * 80
      Rails.logger.info "All orders processed successfully!"
      Rails.logger.info "Job completed at #{Time.current}"
      Rails.logger.info "=" * 80
    end
  end
end

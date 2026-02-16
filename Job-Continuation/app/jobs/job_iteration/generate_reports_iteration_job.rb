# job-iteration example - Nested enumerator pattern
# Demonstrates multi-level iteration: customers → orders
module JobIteration
  class GenerateReportsIterationJob < ApplicationJob
    include ::JobIteration::Iteration
    include Interruptible

    queue_as :default

    # Build nested enumerator: outer (customers) × inner (orders)
    def build_enumerator(cursor:)
      Rails.logger.info "=" * 80
      Rails.logger.info "Building nested enumerator for GenerateReportsIterationJob"
      Rails.logger.info "Resuming from cursor: #{cursor.inspect || 'beginning'}"
      Rails.logger.info "=" * 80

      # Nested enumerator helper
      # Outer: iterate through customers
      # Inner: for each customer, iterate through their orders
      enumerator_builder.nested(
        # Outer enumerator: active customers
        enumerator_builder.active_record_on_records(
          Customer.active,
          cursor: cursor
        ),

        # Inner enumerator: orders for each customer
        # This is a lambda that takes (customer, cursor) and returns an enumerator
        ->(customer, cursor:) {
          Rails.logger.info "Processing customer ##{customer.id}: #{customer.name}"

          enumerator_builder.active_record_on_records(
            customer.orders,
            cursor: cursor
          )
        }
      )
    end

    # Called once per order (inner loop item)
    # Receives both the inner item (order) and outer item (customer)
    def each_iteration(order, customer)
      check_interruption_flag

      # Aggregate order data for the report
      Rails.logger.debug "  Aggregating order ##{order.id} for customer ##{customer.id}"

      # Simulate data aggregation
      sleep(0.05)

      # Check if this is the last order for this customer by ID
      # Since iteration is by primary key, we can check max ID
      if order.id == customer.orders.maximum(:id)
        ReportGenerator.new(customer).generate!
        Rails.logger.info "  ✓ Report generated for customer ##{customer.id}"
      end

      # Checkpoint saved automatically after each order
    end

    # Called once after all iterations complete
    def on_complete
      total_customers = Customer.active.count

      Rails.logger.info "=" * 80
      Rails.logger.info "All #{total_customers} customer reports generated!"
      Rails.logger.info "Job completed at #{Time.current}"
      Rails.logger.info "=" * 80
    end

    # Called on interruption
    def on_shutdown
      cursor = cursor_position
      Rails.logger.info "Job interrupted, checkpoint saved at cursor: #{cursor.inspect}"
    end
  end
end

# Rails 8 Native job continuation example - Nested iteration
# Demonstrates multi-level checkpoints: customers → orders
module RailsNative
  class GenerateReportsJob < ApplicationJob
    include ActiveJob::Continuable
    include Interruptible

    queue_as :default

    def perform
      Rails.logger.info "=" * 80
      Rails.logger.info "Starting GenerateReportsJob (Rails 8 Native - Nested)"
      Rails.logger.info "=" * 80

      total_customers = Customer.active.count
      Rails.logger.info "Found #{total_customers} active customers"

      # Step: Process each customer (outer loop)
      step :process_customers do |customer_step|
        customers_processed = 0

        # Use find_each with cursor for efficient batch processing
        Customer.active.find_each(start: customer_step.cursor) do |customer|
          check_interruption_flag

          Rails.logger.info "Processing customer ##{customer.id}"

          # Step: Process each order for this customer (inner loop)
          step :process_customer_orders do |order_step|
            orders_processed = 0

            # Use find_each for customer's orders
            customer.orders.find_each(start: order_step.cursor) do |order|
              check_interruption_flag

              # Aggregate order data for the report
              Rails.logger.debug "    Aggregating order ##{order.id}"

              # Simulate data aggregation
              sleep(0.05)

              orders_processed += 1

              # Save checkpoint with current order's ID
              order_step.advance! from: order.id
            end

            Rails.logger.debug "  Aggregated #{orders_processed} orders for customer ##{customer.id}"
          end

          # Generate report after all orders processed for this customer
          ReportGenerator.new(customer).generate!
          customers_processed += 1

          # Advance customer cursor with current customer's ID
          customer_step.advance! from: customer.id

          Rails.logger.info "  ✓ Report generated for customer ##{customer.id}"
        end

        Rails.logger.info "Processed #{customers_processed} customers in this run"
      end

      Rails.logger.info "=" * 80
      Rails.logger.info "All customer reports generated!"
      Rails.logger.info "Job completed at #{Time.current}"
      Rails.logger.info "=" * 80
    end
  end
end

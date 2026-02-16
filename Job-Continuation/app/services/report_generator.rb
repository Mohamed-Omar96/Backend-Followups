# Service to generate customer reports
# Demonstrates aggregation and report creation
class ReportGenerator
  attr_reader :customer

  def initialize(customer)
    @customer = customer
  end

  # Generate a complete customer report
  def generate!
    Rails.logger.info "Generating report for customer ##{customer.id} (#{customer.name})"

    report_data = {
      customer_id: customer.id,
      customer_name: customer.name,
      generated_at: Time.current
    }

    # Aggregate order data
    report_data.merge!(aggregate_orders)

    # Calculate metrics
    report_data.merge!(calculate_metrics)

    # Simulate report rendering/storage
    save_report(report_data)

    Rails.logger.info "✓ Report generated for customer ##{customer.id}"

    report_data
  rescue StandardError => e
    Rails.logger.error "✗ Report generation failed for customer ##{customer.id}: #{e.message}"
    raise
  end

  private

  def aggregate_orders
    orders = customer.orders

    {
      total_orders: orders.count,
      pending_orders: orders.pending.count,
      processed_orders: orders.processed.count,
      failed_orders: orders.failed.count,
      total_revenue: orders.processed.sum(:amount),
      average_order_value: orders.processed.average(:amount) || 0
    }
  end

  def calculate_metrics
    # Simulated metric calculation time
    sleep(0.1)

    orders = customer.orders.processed

    {
      first_order_date: orders.minimum(:created_at),
      last_order_date: orders.maximum(:created_at),
      lifetime_value: orders.sum(:amount),
      customer_segment: determine_segment(orders.count)
    }
  end

  def determine_segment(order_count)
    case order_count
    when 0 then "new"
    when 1..5 then "occasional"
    when 6..20 then "regular"
    else "vip"
    end
  end

  def save_report(report_data)
    # Simulated report storage time
    sleep(0.05)

    # In a real application, this would save to database, S3, etc.
    # For demo purposes, we just log it
    Rails.logger.debug "Report data: #{report_data.inspect}"
  end
end

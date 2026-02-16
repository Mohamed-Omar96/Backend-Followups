# Service to process orders with simulated business logic
# Demonstrates realistic processing time and potential errors
class OrderProcessor
  attr_reader :order

  def initialize(order)
    @order = order
  end

  # Process an order through multiple steps
  def process!
    Rails.logger.info "Processing order ##{order.id} (amount: $#{order.amount})"

    # Mark as processing
    order.mark_as_processing!

    # Simulate validation (quick)
    validate_order

    # Simulate payment processing (slow)
    process_payment

    # Simulate inventory check (medium)
    check_inventory

    # Simulate fulfillment setup (quick)
    setup_fulfillment

    # Mark as processed
    order.mark_as_processed!

    Rails.logger.info "✓ Order ##{order.id} processed successfully"
  rescue StandardError => e
    Rails.logger.error "✗ Order ##{order.id} failed: #{e.message}"
    order.mark_as_failed!
    raise
  end

  private

  def validate_order
    # Simulated validation time
    sleep(0.05)

    # Simulate 2% validation error rate (disabled in demo mode)
    return if demo_mode?
    raise "Invalid order data" if rand < 0.02
  end

  def process_payment
    # Simulated payment processing time (slowest step)
    sleep(0.3)

    # Simulate 1% payment failure rate (disabled in demo mode)
    return if demo_mode?
    raise "Payment declined" if rand < 0.01
  end

  def check_inventory
    # Simulated inventory check time
    sleep(0.1)

    # Simulate 1% out of stock (disabled in demo mode)
    return if demo_mode?
    raise "Out of stock" if rand < 0.01
  end

  def demo_mode?
    ENV['DEMO_MODE'].to_s.downcase == 'true'
  end

  def setup_fulfillment
    # Simulated fulfillment setup time
    sleep(0.05)
  end
end

# Seed data generator for Job Continuation Demo
# Supports two modes: quick (for fast demos) and full (for comprehensive testing)

require "faker"

# Determine seed mode from environment variable
# Usage:
#   rails db:seed                    # Default: quick mode
#   SEED_MODE=quick rails db:seed    # Quick mode (30 seconds)
#   SEED_MODE=full rails db:seed     # Full mode (5 minutes)
seed_mode = ENV.fetch("SEED_MODE", "quick").to_sym

# Configuration for each mode
SEED_CONFIGS = {
  quick: {
    customers: 50,
    orders_per_customer: 2,      # 100 orders total
    email_campaigns: 1,
    recipients_per_campaign: [500]
  },
  full: {
    customers: 500,
    orders_per_customer: 20,     # 10,000 orders total
    email_campaigns: 3,
    recipients_per_campaign: [5000, 1000, 500]
  }
}.freeze

config = SEED_CONFIGS[seed_mode]

unless config
  puts "Invalid SEED_MODE: #{seed_mode}. Use 'quick' or 'full'."
  exit 1
end

puts "=" * 80
puts "SEEDING DATABASE - #{seed_mode.upcase} MODE"
puts "=" * 80
puts ""

# Clear existing data
puts "Clearing existing data..."
EmailCampaign.destroy_all
Order.destroy_all
Customer.destroy_all
puts "✓ Database cleared"
puts ""

# ============================================================================
# CUSTOMERS
# ============================================================================
puts "Creating #{config[:customers]} customers..."
start_time = Time.now

customers = []
config[:customers].times do |i|
  customer = Customer.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email
  )
  customers << customer

  # Progress indicator
  if (i + 1) % 50 == 0
    puts "  #{i + 1} customers created..."
  end
end

elapsed = (Time.now - start_time).round(2)
puts "✓ Created #{customers.count} customers in #{elapsed}s"
puts ""

# ============================================================================
# ORDERS
# ============================================================================
total_orders = config[:customers] * config[:orders_per_customer]
puts "Creating #{total_orders} orders (#{config[:orders_per_customer]} per customer)..."
start_time = Time.now

order_count = 0
order_statuses = ["pending", "pending", "pending", "processed", "failed"] # 60% pending

customers.each do |customer|
  config[:orders_per_customer].times do
    Order.create!(
      customer: customer,
      status: order_statuses.sample,
      amount: Faker::Commerce.price(range: 10.0..500.0, as_string: false),
      processed_at: [nil, nil, nil, Faker::Time.backward(days: 30)].sample # 75% unprocessed
    )
    order_count += 1

    # Progress indicator
    if order_count % 500 == 0
      puts "  #{order_count} orders created..."
    end
  end
end

elapsed = (Time.now - start_time).round(2)
puts "✓ Created #{order_count} orders in #{elapsed}s"
puts ""

# ============================================================================
# EMAIL CAMPAIGNS
# ============================================================================
puts "Creating #{config[:email_campaigns]} email campaigns..."
start_time = Time.now

campaigns = []
config[:recipients_per_campaign].each_with_index do |recipient_count, i|
  campaign = EmailCampaign.create!(
    name: "#{Faker::Marketing.buzzwords.titleize} Campaign #{i + 1}",
    subject: Faker::Company.catch_phrase,
    status: "pending",
    sent_count: 0,
    total_recipients: recipient_count
  )
  campaigns << campaign
end

elapsed = (Time.now - start_time).round(2)
puts "✓ Created #{campaigns.count} email campaigns in #{elapsed}s"
puts ""

# ============================================================================
# SUMMARY
# ============================================================================
puts "=" * 80
puts "SEEDING COMPLETE - #{seed_mode.upcase} MODE"
puts "=" * 80
puts ""
puts "Summary:"
puts "  Customers:       #{Customer.count} (#{Customer.active.count} active)"
puts "  Orders:          #{Order.count}"
puts "    - Pending:     #{Order.pending.count}"
puts "    - Processed:   #{Order.processed.count}"
puts "    - Failed:      #{Order.failed.count}"
puts "  Email Campaigns: #{EmailCampaign.count}"
puts "    - Pending:     #{EmailCampaign.pending.count}"
puts "    - Total Recipients: #{EmailCampaign.sum(:total_recipients)}"
puts ""
puts "Ready for demos!"
puts ""

# ============================================================================
# USAGE EXAMPLES
# ============================================================================
if seed_mode == :quick
  puts "Quick mode seeded. Ready for fast demos (~30 second processing time)."
  puts ""
  puts "Try running:"
  puts "  RailsNative::ProcessOrdersJob.perform_later"
  puts "  JobIteration::ProcessOrdersIterationJob.perform_later"
else
  puts "Full mode seeded. Ready for comprehensive testing (~5 minute processing time)."
  puts ""
  puts "Try running:"
  puts "  RailsNative::ProcessOrdersJob.perform_later"
  puts "  RailsNative::GenerateReportsJob.perform_later"
  puts "  RailsNative::BatchEmailJob.perform_later(#{EmailCampaign.first.id})"
end
puts ""
puts "=" * 80

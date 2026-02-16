# Rake tasks for Job Continuation Demo
# Provides convenient commands for running demos, monitoring progress, and interrupting jobs

namespace :demo do
  desc "Seed database with demo data (usage: rake demo:seed[mode] where mode=quick|full)"
  task :seed, [:mode] => :environment do |_t, args|
    mode = args[:mode] || "quick"
    ENV["SEED_MODE"] = mode

    puts "Seeding database in #{mode} mode..."
    Rake::Task["db:seed"].invoke
  end

  desc "Monitor job progress in real-time"
  task monitor: :environment do
    require_relative "../demo/job_monitor"

    monitor = Demo::JobMonitor.new(refresh_interval: 1)
    monitor.start
  end

  desc "Show single snapshot of job progress"
  task snapshot: :environment do
    require_relative "../demo/job_monitor"

    monitor = Demo::JobMonitor.new
    monitor.snapshot
  end

  desc "Run a specific job (usage: rake demo:run[job_type] where job_type=rails_native:orders|job_iteration:orders)"
  task :run, [:job_type, :options] => :environment do |_t, args|
    job_type = args[:job_type] || "rails_native:orders"
    pattern, job_name = job_type.split(":")

    puts "\n" + "=" * 80
    puts "Running Job: #{job_type}"
    puts "=" * 80 + "\n"

    case job_type
    when "rails_native:orders"
      RailsNative::ProcessOrdersJob.perform_later
      puts "✓ RailsNative::ProcessOrdersJob enqueued"

    when "rails_native:reports"
      RailsNative::GenerateReportsJob.perform_later
      puts "✓ RailsNative::GenerateReportsJob enqueued"

    when "rails_native:emails"
      campaign = EmailCampaign.pending.first
      if campaign
        RailsNative::BatchEmailJob.perform_later(campaign.id)
        puts "✓ RailsNative::BatchEmailJob enqueued for campaign: #{campaign.name}"
      else
        puts "✗ No pending email campaigns found. Run: rake demo:seed"
      end

    when "job_iteration:orders"
      JobIteration::ProcessOrdersIterationJob.perform_later
      puts "✓ JobIteration::ProcessOrdersIterationJob enqueued"

    when "job_iteration:reports"
      JobIteration::GenerateReportsIterationJob.perform_later
      puts "✓ JobIteration::GenerateReportsIterationJob enqueued"

    when "job_iteration:emails"
      campaign = EmailCampaign.pending.first
      if campaign
        JobIteration::BatchEmailIterationJob.perform_later(campaign.id)
        puts "✓ JobIteration::BatchEmailIterationJob enqueued for campaign: #{campaign.name}"
      else
        puts "✗ No pending email campaigns found. Run: rake demo:seed"
      end

    else
      puts "Unknown job type: #{job_type}"
      puts ""
      puts "Available job types:"
      puts "  rails_native:orders   - Process orders (Rails 8 Native)"
      puts "  rails_native:reports  - Generate customer reports (Rails 8 Native)"
      puts "  rails_native:emails   - Send email campaign (Rails 8 Native)"
      puts "  job_iteration:orders  - Process orders (job-iteration)"
      puts "  job_iteration:reports - Generate customer reports (job-iteration)"
      puts "  job_iteration:emails  - Send email campaign (job-iteration)"
    end

    puts ""
    puts "Monitor progress with: rake demo:monitor"
    puts ""
  end

  desc "Interrupt all Sidekiq workers"
  task interrupt: :environment do
    require_relative "../demo/interruptor"

    Demo::Interruptor.interrupt_all_workers
  end

  desc "Interrupt after N seconds (usage: rake demo:interrupt_after[10])"
  task :interrupt_after, [:seconds] => :environment do |_t, args|
    require_relative "../demo/interruptor"

    seconds = (args[:seconds] || 10).to_i

    puts "Will interrupt after #{seconds} seconds..."
    Demo::Interruptor.interrupt_after(seconds: seconds)

    puts "Waiting for interruption..."
    sleep(seconds + 2)
  end

  desc "Interrupt when order count reaches N (usage: rake demo:interrupt_at_count[300])"
  task :interrupt_at_count, [:count] => :environment do |_t, args|
    require_relative "../demo/interruptor"

    count = (args[:count] || 100).to_i

    puts "Will interrupt when #{count} orders are processed..."
    Demo::Interruptor.interrupt_after_items(count: count, model_class: Order)

    puts "Monitoring progress..."
    sleep 30
  end

  desc "Show current checkpoint state"
  task show_checkpoints: :environment do
    require_relative "../demo/interruptor"

    Demo::Interruptor.show_checkpoints
  end

  desc "Verify demo setup"
  task verify: :environment do
    puts "\n" + "=" * 80
    puts "DEMO SETUP VERIFICATION"
    puts "=" * 80 + "\n"

    all_good = true

    # Check Ruby version
    print "Ruby version (3.1+): "
    if RUBY_VERSION >= "3.1"
      puts "✓ #{RUBY_VERSION}"
    else
      puts "✗ #{RUBY_VERSION} (need 3.1+)"
      all_good = false
    end

    # Check Rails version
    print "Rails version (8.0+): "
    if Rails::VERSION::MAJOR >= 8
      puts "✓ #{Rails.version}"
    else
      puts "✗ #{Rails.version} (need 8.0+)"
      all_good = false
    end

    # Check Redis connection
    print "Redis connection: "
    begin
      redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
      redis.ping
      puts "✓ Connected"
    rescue StandardError => e
      puts "✗ Failed (#{e.message})"
      all_good = false
    end

    # Check Sidekiq
    print "Sidekiq gem: "
    if defined?(Sidekiq)
      puts "✓ Installed"
    else
      puts "✗ Not found"
      all_good = false
    end

    # Check job-iteration
    print "job-iteration gem: "
    if defined?(JobIteration)
      puts "✓ Installed"
    else
      puts "✗ Not found"
      all_good = false
    end

    # Check database
    print "Database: "
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "✓ Connected"
    rescue StandardError => e
      puts "✗ Failed (#{e.message})"
      all_good = false
    end

    # Check seed data
    print "Seed data: "
    if Order.count > 0 && Customer.count > 0
      puts "✓ Present (#{Order.count} orders, #{Customer.count} customers)"
    else
      puts "⚠️  Empty (run: rake demo:seed)"
    end

    puts ""
    puts "-" * 80

    if all_good
      puts "✅ All checks passed! Ready to run demos."
      puts ""
      puts "Next steps:"
      puts "  1. Start Sidekiq: bundle exec sidekiq -C config/sidekiq.yml"
      puts "  2. Run a demo: rake demo:run[rails_native:orders]"
      puts "  3. Monitor progress: rake demo:monitor"
    else
      puts "❌ Some checks failed. Please fix the issues above."
    end

    puts ""
    puts "=" * 80 + "\n"
  end

  desc "Compare Rails Native vs job-iteration performance"
  task compare: :environment do
    require_relative "../demo/comparison_reporter"

    reporter = Demo::ComparisonReporter.new

    puts "\n" + "=" * 80
    puts "RUNNING COMPARISON DEMO"
    puts "This will take several minutes..."
    puts "=" * 80 + "\n"

    # Reset data
    puts "Resetting test data..."
    Rake::Task["db:reset"].invoke
    ENV["SEED_MODE"] = "quick"
    Rake::Task["db:seed"].invoke

    # Run Rails Native
    puts "\nRunning Rails Native jobs..."
    start_time = Time.now
    RailsNative::ProcessOrdersJob.perform_now
    rails_time = Time.now - start_time

    reporter.record(
      pattern: :rails_native,
      job_name: "ProcessOrders",
      metrics: {
        execution_time: rails_time,
        checkpoint_count: Order.processed.count,
        items_processed: Order.processed.count
      }
    )

    # Reset for job-iteration
    Order.update_all(status: "pending", processed_at: nil)

    # Run job-iteration
    puts "\nRunning job-iteration jobs..."
    start_time = Time.now
    JobIteration::ProcessOrdersIterationJob.perform_now
    iteration_time = Time.now - start_time

    reporter.record(
      pattern: :job_iteration,
      job_name: "ProcessOrders",
      metrics: {
        execution_time: iteration_time,
        checkpoint_count: Order.processed.count,
        items_processed: Order.processed.count
      }
    )

    # Display comparison
    reporter.display
  end

  desc "Clean up all demo data"
  task clean: :environment do
    puts "Cleaning up demo data..."

    EmailCampaign.destroy_all
    Order.destroy_all
    Customer.destroy_all

    # Clear Redis checkpoints
    begin
      redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
      keys = redis.keys("iteration:*")
      redis.del(*keys) if keys.any?
      puts "✓ Cleared #{keys.count} Redis checkpoint(s)"
    rescue StandardError => e
      puts "⚠️  Could not clear Redis: #{e.message}"
    end

    puts "✓ All demo data cleaned"
  end
end

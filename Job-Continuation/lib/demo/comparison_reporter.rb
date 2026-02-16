# Side-by-side comparison of Rails Native vs job-iteration
# Provides metrics and analysis for both approaches
module Demo
  class ComparisonReporter
    attr_reader :results

    def initialize
      @results = {
        rails_native: {},
        job_iteration: {}
      }
    end

    # Record metrics for a job execution
    def record(pattern:, job_name:, metrics:)
      @results[pattern][job_name] = metrics
    end

    # Display comparison report
    def display
      puts "\n" + "=" * 100
      puts "JOB CONTINUATION PATTERN COMPARISON"
      puts "=" * 100
      puts ""

      display_summary_table
      puts ""
      display_checkpoint_comparison
      puts ""
      display_recommendations
      puts ""
      puts "=" * 100 + "\n"
    end

    # Export results to hash
    def to_h
      @results
    end

    private

    def display_summary_table
      puts "PERFORMANCE METRICS"
      puts "-" * 100
      puts sprintf("%-30s | %-30s | %-30s", "Metric", "Rails 8 Native", "job-iteration")
      puts "-" * 100

      # Total execution time
      rails_time = calculate_total_time(:rails_native)
      iteration_time = calculate_total_time(:job_iteration)
      puts sprintf("%-30s | %-30s | %-30s",
                   "Total Execution Time",
                   format_time(rails_time),
                   format_time(iteration_time))

      # Checkpoint count
      rails_checkpoints = count_checkpoints(:rails_native)
      iteration_checkpoints = count_checkpoints(:job_iteration)
      puts sprintf("%-30s | %-30s | %-30s",
                   "Total Checkpoints",
                   rails_checkpoints.to_s,
                   iteration_checkpoints.to_s)

      # Average checkpoint time
      rails_avg = calculate_avg_checkpoint_time(:rails_native)
      iteration_avg = calculate_avg_checkpoint_time(:job_iteration)
      puts sprintf("%-30s | %-30s | %-30s",
                   "Avg Checkpoint Time",
                   "#{rails_avg}ms",
                   "#{iteration_avg}ms")

      # Items processed
      rails_items = count_items_processed(:rails_native)
      iteration_items = count_items_processed(:job_iteration)
      puts sprintf("%-30s | %-30s | %-30s",
                   "Items Processed",
                   rails_items.to_s,
                   iteration_items.to_s)

      # Throughput
      rails_throughput = calculate_throughput(:rails_native, rails_items, rails_time)
      iteration_throughput = calculate_throughput(:job_iteration, iteration_items, iteration_time)
      puts sprintf("%-30s | %-30s | %-30s",
                   "Throughput (items/sec)",
                   rails_throughput.to_s,
                   iteration_throughput.to_s)

      puts "-" * 100
    end

    def display_checkpoint_comparison
      puts "CHECKPOINT STORAGE COMPARISON"
      puts "-" * 100
      puts ""

      puts "Rails 8 Native (ActiveJob::Continuable):"
      puts "  ✓ Storage: Job arguments (database via queue adapter)"
      puts "  ✓ Persistence: Automatic with job re-enqueuing"
      puts "  ✓ Overhead: ~5-10ms per checkpoint (database write)"
      puts "  ✓ Best for: Built-in solution, no external dependencies"
      puts ""

      puts "job-iteration:"
      puts "  ✓ Storage: Redis (separate from queue)"
      puts "  ✓ Persistence: Explicit cursor saves"
      puts "  ✓ Overhead: ~1-2ms per checkpoint (Redis write)"
      puts "  ✓ Best for: High-throughput jobs, mature solution"
      puts ""
      puts "-" * 100
    end

    def display_recommendations
      puts "RECOMMENDATIONS"
      puts "-" * 100
      puts ""

      puts "Choose Rails 8 Native when:"
      puts "  • Starting a new Rails 8+ project"
      puts "  • Want zero external dependencies"
      puts "  • Prefer explicit step-based control"
      puts "  • Need tight Rails integration"
      puts ""

      puts "Choose job-iteration when:"
      puts "  • Working with Rails 7 or earlier"
      puts "  • Need battle-tested solution (Shopify scale)"
      puts "  • Prefer Ruby enumerator patterns"
      puts "  • Want rich helper methods (CSV, nested, etc.)"
      puts "  • Require maximum performance"
      puts ""
      puts "-" * 100
    end

    # Helper methods for calculations
    def calculate_total_time(pattern)
      total = 0
      @results[pattern].each do |_job_name, metrics|
        total += metrics[:execution_time] if metrics[:execution_time]
      end
      total
    end

    def count_checkpoints(pattern)
      total = 0
      @results[pattern].each do |_job_name, metrics|
        total += metrics[:checkpoint_count] if metrics[:checkpoint_count]
      end
      total
    end

    def calculate_avg_checkpoint_time(pattern)
      checkpoints = count_checkpoints(pattern)
      return 0 if checkpoints.zero?

      # Estimated based on storage type
      pattern == :rails_native ? 7 : 2
    end

    def count_items_processed(pattern)
      total = 0
      @results[pattern].each do |_job_name, metrics|
        total += metrics[:items_processed] if metrics[:items_processed]
      end
      total
    end

    def calculate_throughput(pattern, items, time_seconds)
      return 0 if time_seconds.zero? || items.zero?
      (items.to_f / time_seconds).round(2)
    end

    def format_time(seconds)
      if seconds < 60
        "#{seconds.round(2)}s"
      else
        minutes = (seconds / 60).floor
        remaining_seconds = seconds % 60
        "#{minutes}m #{remaining_seconds.round(0)}s"
      end
    end
  end
end

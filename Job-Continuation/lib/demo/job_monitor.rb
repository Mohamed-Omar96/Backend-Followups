# Real-time job progress monitoring for demos
# Displays progress bars and checkpoint information in the terminal
module Demo
  class JobMonitor
    attr_reader :refresh_interval

    def initialize(refresh_interval: 1)
      @refresh_interval = refresh_interval
      @running = false
    end

    # Start monitoring in a loop
    def start
      @running = true
      puts "\n" + "=" * 80
      puts "JOB MONITOR - Real-time Progress"
      puts "Press Ctrl+C to stop monitoring"
      puts "=" * 80 + "\n"

      while @running
        clear_screen
        display_stats
        sleep(refresh_interval)
      end
    rescue Interrupt
      @running = false
      puts "\n\nMonitoring stopped."
    end

    # Stop monitoring
    def stop
      @running = false
    end

    # Display single snapshot
    def snapshot
      display_stats
    end

    private

    def clear_screen
      # ANSI escape code to clear screen and move cursor to top
      print "\e[2J\e[H"
    end

    def display_stats
      puts "=" * 80
      puts "Job Continuation Monitor - #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
      puts "=" * 80
      puts ""

      # Order Processing Stats
      display_order_stats

      # Customer Report Stats
      display_customer_stats

      # Email Campaign Stats
      display_campaign_stats

      puts ""
      puts "-" * 80

      # Sidekiq Queue Stats
      display_queue_stats

      puts "-" * 80
      puts ""
    end

    def display_order_stats
      total = Order.count
      pending = Order.pending.count
      processing = Order.processing.count
      processed = Order.processed.count
      failed = Order.failed.count

      puts "📦 ORDER PROCESSING"
      puts "  Total: #{total} | Pending: #{pending} | Processing: #{processing} | Processed: #{processed} | Failed: #{failed}"

      if total > 0
        progress = (processed.to_f / total * 100).round(1)
        bar = progress_bar(progress, 50)
        puts "  Progress: #{bar} #{progress}%"
      end

      puts ""
    end

    def display_customer_stats
      total = Customer.active.count
      puts "👥 CUSTOMER REPORTS"
      puts "  Active Customers: #{total}"

      # In a real implementation, we'd track report generation progress
      # For now, just show customer count
      puts ""
    end

    def display_campaign_stats
      campaigns = EmailCampaign.all

      puts "📧 EMAIL CAMPAIGNS"

      if campaigns.any?
        campaigns.each do |campaign|
          status_icon = case campaign.status
                        when "pending" then "⏸"
                        when "in_progress" then "▶️"
                        when "completed" then "✅"
                        when "failed" then "❌"
                        end

          puts "  #{status_icon} #{campaign.name}"
          puts "     Sent: #{campaign.sent_count}/#{campaign.total_recipients} (#{campaign.progress_percentage}%)"

          if campaign.in_progress? || campaign.completed?
            bar = progress_bar(campaign.progress_percentage, 40)
            puts "     #{bar}"
          end
        end
      else
        puts "  No campaigns"
      end

      puts ""
    end

    def display_queue_stats
      # Sidekiq queue stats
      begin
        require "sidekiq/api"

        stats = Sidekiq::Stats.new
        queues = Sidekiq::Queue.all

        puts "⚙️  SIDEKIQ STATUS"
        puts "  Processed: #{stats.processed} | Failed: #{stats.failed} | Queued: #{stats.enqueued}"

        if queues.any?
          puts "  Queues:"
          queues.each do |queue|
            puts "    - #{queue.name}: #{queue.size} jobs" if queue.size > 0
          end
        end
      rescue StandardError => e
        puts "⚙️  SIDEKIQ STATUS: Unable to connect (#{e.message})"
      end
    end

    def progress_bar(percentage, width = 50)
      filled = (percentage / 100.0 * width).round
      empty = width - filled

      "[" + ("█" * filled) + ("░" * empty) + "]"
    end
  end
end

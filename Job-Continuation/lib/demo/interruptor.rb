# Controlled job interruption for demos
# Provides methods to interrupt jobs at specific points
module Demo
  class Interruptor
    class << self
      # Interrupt after a specified time duration
      def interrupt_after(seconds:, job_class: nil)
        Thread.new do
          sleep seconds

          if job_class
            worker_pid = find_worker_processing(job_class)

            if worker_pid
              puts "\n⚠️  Sending SIGTERM to Sidekiq worker (PID: #{worker_pid})..."
              Process.kill("TERM", worker_pid)
              puts "✓ Interruption signal sent"
            else
              puts "⚠️  No worker found processing #{job_class}"
            end
          else
            # Interrupt all Sidekiq workers
            interrupt_all_workers
          end
        end
      end

      # Interrupt after processing N items
      def interrupt_after_items(count:, model_class:)
        Thread.new do
          loop do
            case model_class.name
            when "Order"
              processed = Order.processed.count
            when "Customer"
              processed = Customer.count  # Simplified
            else
              processed = 0
            end

            if processed >= count
              interrupt_all_workers
              break
            end

            sleep 0.5
          end
        end
      end

      # Interrupt at a specific record ID
      def interrupt_at(model_class:, record_id:)
        Thread.new do
          loop do
            case model_class.name
            when "Order"
              record = Order.find_by(id: record_id)
              if record && record.processed_at.present?
                puts "\n⚠️  Target record processed, interrupting..."
                interrupt_all_workers
                break
              end
            end

            sleep 0.5
          end
        end
      end

      # Set an interruption flag for a specific job
      def set_interruption_flag(job_id:)
        flag_key = "interrupt:#{job_id}"
        Rails.cache.write(flag_key, true, expires_in: 1.hour)
        puts "✓ Interruption flag set for job #{job_id}"
      end

      # Interrupt all Sidekiq workers
      def interrupt_all_workers
        pids = find_sidekiq_pids

        if pids.any?
          puts "\n⚠️  Sending SIGTERM to #{pids.count} Sidekiq worker(s)..."

          pids.each do |pid|
            begin
              Process.kill("TERM", pid)
              puts "  ✓ Signal sent to PID #{pid}"
            rescue Errno::ESRCH
              puts "  ⚠️  PID #{pid} not found"
            rescue Errno::EPERM
              puts "  ⚠️  Permission denied for PID #{pid}"
            end
          end

          puts "✓ Interruption signals sent"
        else
          puts "⚠️  No Sidekiq workers found"
        end
      end

      # Find Sidekiq process IDs
      def find_sidekiq_pids
        pids = []

        begin
          output = `ps aux | grep sidekiq | grep -v grep`
          lines = output.split("\n")

          lines.each do |line|
            # Parse PID from ps output (usually second column)
            parts = line.split
            pid = parts[1].to_i
            pids << pid if pid > 0
          end
        rescue StandardError => e
          puts "Error finding Sidekiq PIDs: #{e.message}"
        end

        pids
      end

      # Find worker processing a specific job class (simplified)
      def find_worker_processing(job_class)
        # In a real implementation, we'd query Sidekiq's working set
        # For demo purposes, just return first Sidekiq worker PID
        find_sidekiq_pids.first
      end

      # Show current checkpoint state
      def show_checkpoints
        puts "\n" + "=" * 80
        puts "CHECKPOINT STATE"
        puts "=" * 80

        # Check Rails native checkpoints (in job arguments)
        # This would require accessing the queue adapter
        puts "\nRails Native Checkpoints:"
        puts "  (Stored in job arguments in queue)"

        # Check job-iteration checkpoints (in Redis)
        puts "\njob-iteration Checkpoints:"

        begin
          redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
          keys = redis.keys("iteration:*")

          if keys.any?
            keys.each do |key|
              cursor = redis.get(key)
              puts "  #{key}: #{cursor}"
            end
          else
            puts "  No active checkpoints"
          end
        rescue StandardError => e
          puts "  Unable to connect to Redis: #{e.message}"
        end

        puts "=" * 80 + "\n"
      end
    end
  end
end

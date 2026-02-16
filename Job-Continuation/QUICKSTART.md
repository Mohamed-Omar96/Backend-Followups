# Quick Start Guide

## What's Been Implemented

✅ **Complete Rails 8 Application** with:
- 3 database models (Customer, Order, EmailCampaign)
- Rails 8 Native jobs (ActiveJob::Continuable)
- job-iteration jobs (Shopify pattern)
- Shared services and concerns
- Sidekiq configuration
- Seed data generator (quick & full modes)
- Demo infrastructure (monitor, interruptor, reporter)
- Rake tasks for all demo operations
- Automated demo scripts

## Prerequisites

Before running demos, you need:

1. **Ruby 3.3.6** ✓ (already set via .tool-versions)
2. **Rails 8.1.2** ✓ (already installed)
3. **Redis** ⚠️ (needs to be started)

### Start Redis

**macOS (Homebrew):**
```bash
brew services start redis
# or for one-time: redis-server
```

**Linux:**
```bash
sudo systemctl start redis
# or: redis-server
```

**Docker:**
```bash
docker run -d -p 6379:6379 redis:latest
```

## Running Your First Demo

### Option 1: Quick Test (Manual)

1. **Start Redis** (see above)

2. **Start Sidekiq**:
   ```bash
   bundle exec sidekiq -C config/sidekiq.yml
   ```

3. **In another terminal, enqueue a job**:
   ```bash
   bundle exec rake demo:run[rails_native:orders]
   ```

4. **In another terminal, monitor progress**:
   ```bash
   bundle exec rake demo:monitor
   ```

### Option 2: Automated Demo

1. **Start Redis** (see above)

2. **Run the automated demo**:
   ```bash
   ./script/demo_rails_native
   ```

   This will:
   - Start Sidekiq automatically
   - Enqueue the job
   - Interrupt it after 10 seconds
   - Resume from checkpoint
   - Show final results

## Available Demos

### Rails 8 Native Pattern
```bash
./script/demo_rails_native      # Automated demo with interruption
rake demo:run[rails_native:orders]      # Simple order processing
rake demo:run[rails_native:reports]     # Nested customer reports
rake demo:run[rails_native:emails]      # Batch email campaign
```

### job-iteration Pattern
```bash
./script/demo_job_iteration     # Automated demo with interruption
rake demo:run[job_iteration:orders]     # Simple order processing
rake demo:run[job_iteration:reports]    # Nested iteration
rake demo:run[job_iteration:emails]     # Batch processing
```

### Comparison
```bash
./script/demo_comparison        # Side-by-side performance comparison
```

## Key Commands

### Setup & Data
```bash
./script/setup                  # Run once to set everything up
rake demo:seed[quick]           # 100 orders (~30 second demo)
rake demo:seed[full]            # 10,000 orders (~5 minute demo)
rake demo:verify                # Check if everything is configured
```

### Monitoring
```bash
rake demo:monitor               # Real-time progress dashboard
rake demo:snapshot              # Single progress snapshot
rake demo:show_checkpoints      # Show checkpoint state
```

### Job Control
```bash
rake demo:run[job_type]         # Enqueue a specific job
rake demo:interrupt             # Send SIGTERM to all workers
rake demo:interrupt_after[10]   # Auto-interrupt after 10 seconds
```

### Cleanup
```bash
rake demo:clean                 # Remove all demo data
rake db:reset                   # Reset database completely

# Reset orders to pending (after seeding)
bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"

# Complete reset workflow (clean slate)
rake demo:clean && rake demo:seed[quick] && bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"
```

## Project Structure

```
job-continuation-demo/
├── app/
│   ├── jobs/
│   │   ├── rails_native/       # Rails 8 Continuable jobs
│   │   │   ├── process_orders_job.rb
│   │   │   ├── generate_reports_job.rb
│   │   │   └── batch_email_job.rb
│   │   ├── job_iteration/      # job-iteration jobs
│   │   │   ├── process_orders_iteration_job.rb
│   │   │   ├── generate_reports_iteration_job.rb
│   │   │   └── batch_email_iteration_job.rb
│   │   └── concerns/
│   │       └── interruptible.rb
│   ├── models/
│   │   ├── customer.rb
│   │   ├── order.rb
│   │   └── email_campaign.rb
│   └── services/
│       ├── order_processor.rb
│       ├── email_sender.rb
│       └── report_generator.rb
├── lib/
│   ├── demo/
│   │   ├── job_monitor.rb
│   │   ├── interruptor.rb
│   │   └── comparison_reporter.rb
│   └── tasks/
│       └── demo.rake
├── script/
│   ├── setup
│   ├── demo_rails_native
│   ├── demo_job_iteration
│   └── demo_comparison
├── AGENTS.md                   # Comprehensive developer guide
├── CLAUDE.md                   # AI agent reference
├── plan.md                     # Implementation plan
└── README.md                   # Quick start

```

## Troubleshooting

### Redis Connection Failed
```bash
# Start Redis
redis-server

# Or with Homebrew
brew services start redis

# Verify it's running
redis-cli ping
# Should return: PONG
```

### Sidekiq Not Processing Jobs
```bash
# Check if Sidekiq is running
ps aux | grep sidekiq

# Start Sidekiq
bundle exec sidekiq -C config/sidekiq.yml

# Check queue status
rake demo:snapshot
```

### No Pending Orders or Mixed Statuses

The seed file creates orders with **mixed statuses** (60% pending, some processed, some failed) to simulate realistic scenarios. For a clean demo with all pending orders:

```bash
# Complete reset workflow
rake demo:clean
rake demo:seed[quick]
bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"

# Verify clean state
rake demo:snapshot
# Should show: Total: 100 | Pending: 100 | Processed: 0
```

### Jobs Not Resuming After Interruption
This is normal! The checkpoint resumption happens automatically when:
1. The worker restarts
2. Picks up the re-enqueued job from the queue
3. Job resumes from saved checkpoint

## Next Steps

1. **Run the automated demos** to see interruption and resumption in action
2. **Read AGENTS.md** for comprehensive documentation
3. **Explore the code** in `app/jobs/` to understand the patterns
4. **Try interrupting at different points** using the rake tasks
5. **Compare both patterns** with `./script/demo_comparison`

## Documentation

- **QUICKSTART.md** (this file) - Get up and running fast
- **README.md** - Project overview
- **AGENTS.md** - Comprehensive guide (architecture, testing, troubleshooting)
- **CLAUDE.md** - AI agent reference
- **plan.md** - Implementation plan and design decisions

---

**Ready to start?**

```bash
# 1. Start Redis
redis-server

# 2. Run automated demo
./script/demo_rails_native
```

Enjoy exploring job continuation patterns! 🚀

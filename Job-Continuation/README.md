# Job Continuation Demo

Practical demonstration of **job continuation patterns** in Ruby on Rails, comparing **Rails 8 Native** (ActiveJob::Continuable) and **Shopify's job-iteration** gem.

## What This Demonstrates

Learn how to build **resilient background jobs** that can be safely interrupted and resumed without losing progress—critical for cloud environments with deployments, pod evictions, and infrastructure changes.

### Two Approaches Compared

| Rails 8 Native | Shopify job-iteration |
|----------------|----------------------|
| Built into Rails 8 | Requires gem |
| Step-based API | Enumerator pattern |
| Checkpoints in job args | Checkpoints in Redis |
| Perfect for new projects | Battle-tested at scale |

## Prerequisites

Before you start, ensure you have:

- ✅ **Ruby 3.1+** (This project uses 3.3.6)
- ✅ **Rails 8.0+** (Already included)
- ✅ **Redis** (Required for Sidekiq and job-iteration)
- ✅ **Git** (For version control)

### Install Redis

**macOS (Homebrew):**
```bash
brew install redis
brew services start redis
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install redis-server
sudo systemctl start redis
```

**Verify Redis is running:**
```bash
redis-cli ping
# Should return: PONG
```

## Important Note for zsh Users

If you're using zsh (the default shell on macOS), you need to **quote rake tasks with square brackets** or escape them:

```bash
# ✅ Correct (quoted)
bundle exec rake 'demo:run[rails_native:orders]'

# ✅ Correct (escaped)
bundle exec rake demo:run\[rails_native:orders\]

# ❌ Wrong (will give "no matches found" error)
bundle exec rake demo:run[rails_native:orders]
```

**Why?** zsh treats square brackets as special glob characters. All rake task examples in this README use quoted syntax.

## Quick Start (5 Minutes)

### Step 1: Install Dependencies

```bash
bundle install
```

**Expected output:**
```
Bundle complete! 27 Gemfile dependencies, 136 gems now installed.
```

### Step 2: Setup Database

```bash
bundle exec rails db:create db:migrate
```

**Expected output:**
```
Created database 'storage/development.sqlite3'
Created database 'storage/test.sqlite3'
== 20260202073442 CreateCustomers: migrated
== 20260202073451 CreateOrders: migrated
== 20260202073503 CreateEmailCampaigns: migrated
```

### Step 3: Seed Demo Data

```bash
SEED_MODE=quick bundle exec rails db:seed
```

**Expected output:**
```
✓ Created 50 customers
✓ Created 100 orders
  - Pending: 61
  - Processed: 19
  - Failed: 20
✓ Created 1 email campaign
Ready for demos!
```

### Step 4: Verify Setup

```bash
bundle exec rake demo:verify
```

**Expected output:**
```
✓ Ruby version (3.1+): 3.3.6
✓ Rails version (8.0+): 8.1.2
✓ Redis connection: Connected
✓ Sidekiq gem: Installed
✓ job-iteration gem: Installed
✓ Database: Connected
✓ Seed data: Present (100 orders, 50 customers)

✅ All checks passed! Ready to run demos.
```

## Running Your First Demo

### Option 1: Automated Demo (Recommended)

This will automatically show you job interruption and resumption:

```bash
./script/demo_rails_native
```

**What happens:**
1. ✅ Starts Sidekiq worker automatically
2. ✅ Enqueues job to process 61 pending orders
3. ✅ Processes ~20 orders in 10 seconds
4. ⚠️ Simulates interruption (SIGTERM)
5. 📊 Shows checkpoint state (cursor position saved)
6. ▶️ Resumes from checkpoint
7. ✅ Completes all remaining orders
8. 📈 Shows final statistics

**Expected output:**
```
==========================================
Rails 8 Native Demo
ActiveJob::Continuable Pattern
==========================================

✓ Sidekiq started
✓ Reset 61 pending orders
✓ Job enqueued

Job is processing... (monitoring for 10 seconds)

⚠️  Simulating interruption (SIGTERM)...
✓ Workers interrupted

Checkpoint state after interruption:
  Step: process_orders
  Cursor: 23

✓ Worker restarted

Results:
  Total orders: 100
  Processed: 61
  Success rate: 61.0%

✅ Job completed with checkpoint recovery!
```

### Option 2: Manual Demo (For Learning)

Run each component separately to understand the flow:

**Terminal 1 - Start Sidekiq:**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

**Terminal 2 - Monitor Progress:**
```bash
bundle exec rake demo:monitor
```

**Terminal 3 - Enqueue Job:**
```bash
bundle exec rake 'demo:run[rails_native:orders]'
```

**Note for zsh users**: Always quote rake tasks with square brackets or escape them: `rake 'task[arg]'` or `rake task\[arg\]`

**Wait 10 seconds, then in Terminal 1:**
```
Press Ctrl+C
```

**Check checkpoint state:**
```bash
bundle exec rake demo:show_checkpoints
```

**Restart Sidekiq (Terminal 1):**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

Watch the job resume in Terminal 2!

## All Available Demos

### 1. Simple Order Processing

**Rails 8 Native:**
```bash
./script/demo_rails_native
# OR
bundle exec rake 'demo:run[rails_native:orders]'
```

**job-iteration:**
```bash
./script/demo_job_iteration
# OR
bundle exec rake 'demo:run[job_iteration:orders]'
```

### 2. Nested Customer Reports

Demonstrates nested iteration (customers → orders):

```bash
bundle exec rake 'demo:run[rails_native:reports]'
bundle exec rake 'demo:run[job_iteration:reports]'
```

### 3. Batch Email Campaign

Demonstrates batch processing with checkpoint per batch:

```bash
bundle exec rake 'demo:run[rails_native:emails]'
bundle exec rake 'demo:run[job_iteration:emails]'
```

### 4. Side-by-Side Comparison

Compare both approaches with performance metrics:

```bash
./script/demo_comparison
```

**Output includes:**
- Execution time comparison
- Checkpoint count
- Throughput (items/sec)
- Checkpoint storage comparison
- Feature comparison
- Recommendations

## Running Tests

### Run All Tests

```bash
bundle exec rspec
```

**Expected output:**
```
38 examples, 0 failures

Finished in 1.03 seconds
```

### Run Specific Test Types

**Model tests only:**
```bash
bundle exec rspec spec/models
# 21 examples, 0 failures
```

**Job tests only:**
```bash
bundle exec rspec spec/jobs
# 9 examples, 0 failures
```

**Integration tests:**
```bash
bundle exec rspec spec/integration
# 6 examples, 0 failures
```

**Service tests:**
```bash
bundle exec rspec spec/services
# 2 examples, 0 failures
```

### Run Tests with Documentation Format

```bash
bundle exec rspec --format documentation
```

This shows each test with its description.

## Key Commands Reference

### Setup & Data Management

```bash
# Initial setup (run once)
./script/setup

# Seed data - Quick mode (100 orders, ~30 seconds to process)
bundle exec rake 'demo:seed[quick]'

# Seed data - Full mode (10,000 orders, ~5 minutes to process)
bundle exec rake 'demo:seed[full]'

# Verify setup
bundle exec rake demo:verify

# Clean all demo data
bundle exec rake demo:clean

# Reset database completely
bundle exec rails db:reset
```

### Running Jobs

```bash
# Start Sidekiq worker
bundle exec sidekiq -C config/sidekiq.yml

# Enqueue specific job
bundle exec rake 'demo:run[rails_native:orders]'
bundle exec rake 'demo:run[job_iteration:orders]'
bundle exec rake 'demo:run[rails_native:reports]'
bundle exec rake 'demo:run[rails_native:emails]'
```

### Monitoring & Control

```bash
# Real-time progress dashboard (updates every second)
bundle exec rake demo:monitor

# Single snapshot of current progress
bundle exec rake demo:snapshot

# Show checkpoint state
bundle exec rake demo:show_checkpoints

# Interrupt all workers (sends SIGTERM)
bundle exec rake demo:interrupt

# Auto-interrupt after N seconds
bundle exec rake 'demo:interrupt_after[10]'
```

### Testing

```bash
# Run all tests
bundle exec rspec

# Run tests with coverage
bundle exec rspec --format documentation

# Run specific test file
bundle exec rspec spec/models/order_spec.rb

# Run specific test
bundle exec rspec spec/models/order_spec.rb:35
```

## Troubleshooting

### Redis Not Running

**Symptom:**
```
✗ Redis connection: Failed (Connection refused)
```

**Solution:**
```bash
# Start Redis
redis-server

# Or with Homebrew (macOS)
brew services start redis

# Verify
redis-cli ping  # Should return PONG
```

### Sidekiq Not Processing Jobs

**Check if Sidekiq is running:**
```bash
ps aux | grep sidekiq
```

**Start Sidekiq:**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

**Check queue status:**
```bash
bundle exec rake demo:snapshot
```

### No Pending Orders or Mixed Status Orders

**Symptom:**
```
Pending: 57 | Processed: 24 | Failed: 19
(Mixed statuses after seeding)
```

**Solution:**

The seed file intentionally creates orders with mixed statuses (60% pending, some processed, some failed) to simulate realistic scenarios. For clean demo runs, reset all orders to pending:

```bash
# Complete reset workflow
bundle exec rake demo:clean
bundle exec rake 'demo:seed[quick]'
bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"

# Verify clean state
bundle exec rake demo:snapshot
# Should show: Total: 100 | Pending: 100 | Processed: 0 | Failed: 0
```

**Quick one-liner:**
```bash
bundle exec rake demo:clean && bundle exec rake 'demo:seed[quick]' && bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"
```

### Tests Failing

**Ensure test database is set up:**
```bash
RAILS_ENV=test bundle exec rails db:create db:migrate
```

**Clear test cache:**
```bash
bundle exec rails db:test:prepare
```

## Understanding the Output

### Progress Monitor

```
================================================================================
Job Continuation Monitor - 2026-02-02 10:30:45
================================================================================

📦 ORDER PROCESSING
  Total: 100 | Pending: 41 | Processing: 0 | Processed: 39 | Failed: 20
  Progress: [███████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░] 39.0%

📧 EMAIL CAMPAIGNS
  ▶️ Marketing Campaign 1
     Sent: 250/500 (50.0%)
     [████████████████████                    ]

⚙️  SIDEKIQ STATUS
  Processed: 39 | Failed: 0 | Queued: 0
```

### Checkpoint State

```
================================================================================
CHECKPOINT STATE
================================================================================

Rails Native Checkpoints:
  (Stored in job arguments in queue)

job-iteration Checkpoints:
  iteration:JobIteration::ProcessOrdersIterationJob:abc123: 347

================================================================================
```

This shows:
- **Rails Native**: Checkpoints stored in job arguments (database)
- **job-iteration**: Checkpoints stored in Redis with cursor value (347 = last processed order ID)

## Project Structure

```
job-continuation-demo/
├── app/
│   ├── jobs/
│   │   ├── rails_native/              # Rails 8 Continuable jobs
│   │   │   ├── process_orders_job.rb
│   │   │   ├── generate_reports_job.rb
│   │   │   └── batch_email_job.rb
│   │   ├── job_iteration/             # job-iteration jobs
│   │   │   ├── process_orders_iteration_job.rb
│   │   │   ├── generate_reports_iteration_job.rb
│   │   │   └── batch_email_iteration_job.rb
│   │   └── concerns/
│   │       └── interruptible.rb       # Interruption helpers
│   ├── models/
│   │   ├── customer.rb
│   │   ├── order.rb
│   │   └── email_campaign.rb
│   └── services/
│       ├── order_processor.rb          # Simulates order processing
│       ├── email_sender.rb             # Simulates email sending
│       └── report_generator.rb         # Generates customer reports
├── lib/
│   ├── demo/
│   │   ├── job_monitor.rb             # Real-time progress display
│   │   ├── interruptor.rb             # Controlled interruption
│   │   └── comparison_reporter.rb     # Performance comparison
│   └── tasks/
│       └── demo.rake                  # 15+ rake tasks
├── script/
│   ├── setup                          # Initial setup
│   ├── demo_rails_native              # Automated Rails 8 demo
│   ├── demo_job_iteration             # Automated job-iteration demo
│   └── demo_comparison                # Side-by-side comparison
├── spec/
│   ├── models/                        # 21 model tests
│   ├── services/                      # 2 service tests
│   ├── jobs/                          # 9 job tests
│   ├── integration/                   # 6 integration tests
│   └── support/                       # Test helpers
├── config/
│   ├── initializers/
│   │   ├── sidekiq.rb                # Sidekiq configuration
│   │   └── job_iteration.rb          # job-iteration configuration
│   └── sidekiq.yml                   # Worker settings
├── db/
│   ├── migrate/                      # Database migrations
│   └── seeds.rb                      # Demo data generator
├── AGENTS.md                         # Comprehensive developer guide
├── CLAUDE.md                         # AI agent reference
├── QUICKSTART.md                     # Quick start guide
├── plan.md                           # Implementation plan
└── README.md                         # This file
```

## Documentation

- **README.md** (this file) - Complete setup and usage guide
- **QUICKSTART.md** - Quick start for impatient developers
- **AGENTS.md** - Comprehensive developer guide with:
  - Architecture deep dive
  - Code walkthroughs
  - Testing strategies
  - Troubleshooting
  - Advanced topics
- **CLAUDE.md** - AI agent reference
- **plan.md** - Implementation plan and design decisions

## Demo Scenarios Explained

### Scenario 1: Simple Order Processing
- **What it does**: Processes 61 pending orders sequentially
- **Demonstrates**: Basic checkpoint and resume flow
- **Processing time**: ~30 seconds (without interruption)
- **Key learning**: How cursors track progress

### Scenario 2: Nested Customer Reports
- **What it does**: Generates reports for 50 customers (analyzing their orders)
- **Demonstrates**: Multi-level checkpoints (outer: customers, inner: orders)
- **Processing time**: ~45 seconds
- **Key learning**: Nested iteration patterns

### Scenario 3: Batch Email Campaign
- **What it does**: Sends 500 emails in batches of 50
- **Demonstrates**: Checkpoint frequency trade-offs
- **Processing time**: ~60 seconds
- **Key learning**: Batch vs per-item checkpointing

## Real-World Use Cases

This pattern is essential for:

- ✅ **Data migrations** - Process millions of records without timeout
- ✅ **Batch operations** - Send emails, generate reports, sync data
- ✅ **API synchronization** - Fetch paginated data from external APIs
- ✅ **Background processing** - Handle user uploads, video transcoding
- ✅ **Cleanup tasks** - Archive old records, remove orphaned files
- ✅ **Report generation** - Aggregate data from multiple sources
- ✅ **Bulk updates** - Update prices, recalculate scores, etc.

## Key Takeaways

✅ **Checkpoints prevent progress loss** - Resume exactly where you left off
✅ **Cloud-friendly** - Handle pod restarts and deployments gracefully
✅ **No duplicates** - Proper cursor management ensures exactly-once processing
✅ **Testable** - Multiple interruption methods for different scenarios
✅ **Production-ready** - Both patterns battle-tested at scale

## When to Use Each Pattern

### Use Rails 8 Native when:
- ✅ Starting a new Rails 8+ project
- ✅ Want zero external dependencies
- ✅ Prefer explicit step-based control
- ✅ Need tight Rails integration
- ✅ Like clear separation of processing stages

### Use job-iteration when:
- ✅ Working with Rails 7 or earlier
- ✅ Need established, proven solution
- ✅ Prefer Ruby enumerator patterns
- ✅ Want rich helper methods (CSV, nested, etc.)
- ✅ Require Shopify-scale reliability
- ✅ Need maximum performance (Redis checkpoints faster than DB)

## Next Steps

1. ✅ **Run the setup**: `./script/setup`
2. ✅ **Run the automated demo**: `./script/demo_rails_native`
3. ✅ **Read the code**: Start with `app/jobs/rails_native/process_orders_job.rb`
4. ✅ **Compare patterns**: Run `./script/demo_comparison`
5. ✅ **Deep dive**: Read `AGENTS.md` for comprehensive explanations
6. ✅ **Run tests**: `bundle exec rspec`
7. ✅ **Experiment**: Try interrupting at different points

## Presenting This Demo

### For Quick Demo (5 minutes)
```bash
./script/demo_rails_native
```
Show the interruption and resumption in action.

### For Technical Deep Dive (15 minutes)
1. Run `bundle exec rake demo:verify` to show setup
2. Open `app/jobs/rails_native/process_orders_job.rb` to explain code
3. Run manual demo in 3 terminals to show components
4. Show checkpoint state with `rake demo:show_checkpoints`
5. Compare with job-iteration version
6. Run tests to show quality

### For Architecture Discussion (30 minutes)
1. Run comparison demo
2. Review `AGENTS.md` architecture section
3. Discuss trade-offs between patterns
4. Show nested iteration example
5. Discuss production deployment considerations

## Contributing

This is an educational demo project. Improvements welcome!

- 📖 **Documentation**: Update `AGENTS.md`
- 🔧 **Features**: Add new job examples
- 🧪 **Tests**: Improve test coverage
- 🐛 **Bugs**: Submit PRs with failing tests

## Resources

- [Rails 8 ActiveJob::Continuable Docs](https://edgeapi.rubyonrails.org/classes/ActiveJob/Continuable.html)
- [Shopify job-iteration GitHub](https://github.com/Shopify/job-iteration)
- [Sidekiq Best Practices](https://github.com/mperham/sidekiq/wiki/Best-Practices)
- [Ruby Enumerators Guide](https://ruby-doc.org/core-3.1.0/Enumerator.html)

## License

MIT - Free to use for learning and demonstrations

---

**Ready to start?** Run `./script/setup` then `./script/demo_rails_native` 🚀

**Questions?** Check `AGENTS.md` for comprehensive documentation.

**Found this helpful?** ⭐ Star the repo and share with your team!

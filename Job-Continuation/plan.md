# Job Continuation Demo - Implementation Plan

## Project Overview

Create two demonstration examples showcasing job continuation/interruption patterns for backend teams:
1. **Rails 8 Native**: ActiveJob::Continuable (step-based continuation)
2. **Shopify job-iteration**: Established gem pattern (enumerator-based)

Both will use Sidekiq adapter with Redis for checkpoints, demonstrating interruption and resumption in a realistic e-commerce scenario.

## Architecture Decision

**Single Rails 8 Application with Dual Implementations**

Benefits:
- Easy side-by-side comparison
- Shared data model and demo infrastructure
- Single setup reduces complexity
- Realistic: teams need to choose between patterns

## Project Structure

```
job-continuation-demo/
├── README.md                              # Quick start guide
├── plan.md                                # Implementation plan and architecture decisions
├── agents.md                              # Comprehensive developer guide
├── claude.md                              # Brief reference to agents.md
├── Gemfile                                # Rails 8, Sidekiq, job-iteration
├── config/
│   ├── initializers/
│   │   ├── sidekiq.rb                    # Sidekiq + Redis config
│   │   └── job_iteration.rb              # job-iteration setup
│   └── sidekiq.yml                        # Worker configuration
├── app/
│   ├── jobs/
│   │   ├── concerns/
│   │   │   └── interruptible.rb          # Shared interruption helpers
│   │   ├── rails_native/
│   │   │   ├── process_orders_job.rb     # Simple: 1000 orders
│   │   │   ├── generate_reports_job.rb   # Nested: customers → orders
│   │   │   └── batch_email_job.rb        # Batched: 5000 emails
│   │   └── job_iteration/
│   │       ├── process_orders_iteration_job.rb
│   │       ├── generate_reports_iteration_job.rb
│   │       └── batch_email_iteration_job.rb
│   ├── models/
│   │   ├── order.rb
│   │   ├── customer.rb
│   │   └── email_campaign.rb
│   └── services/
│       ├── order_processor.rb            # Simulates slow processing
│       └── email_sender.rb
├── db/
│   ├── migrate/                          # Orders, customers, campaigns
│   └── seeds.rb                          # Realistic demo data (Faker)
├── lib/
│   ├── tasks/
│   │   └── demo.rake                     # Demo orchestration tasks
│   └── demo/
│       ├── job_monitor.rb                # Real-time progress display
│       ├── interruptor.rb                # Controlled interruption
│       └── comparison_reporter.rb        # Side-by-side metrics
└── script/
    ├── setup                             # Initial setup
    ├── demo_rails_native                 # Run Rails 8 demo
    ├── demo_job_iteration                # Run job-iteration demo
    └── demo_comparison                   # Compare both approaches
```

## Demo Scenario: E-commerce Order Processing

Three jobs of increasing complexity:

### Job 1: Process Orders (Simple)
- **Data**: 1000 orders
- **Processing**: Validate, calculate costs, update status
- **Demo**: Interrupt after ~300 orders, resume from checkpoint
- **Time**: ~0.5s per order = ~8 minutes total

### Job 2: Generate Customer Reports (Nested)
- **Data**: 100 customers, 50 orders each
- **Processing**: Aggregate per customer, generate report
- **Demo**: Interrupt during 40th customer, resume at 41st
- **Shows**: Nested iteration patterns

### Job 3: Batch Email Campaign (Complex)
- **Data**: 5000 recipients in batches of 50
- **Processing**: Personalize and send emails
- **Demo**: Interrupt during batch 30, resume at 31
- **Shows**: Batch processing with checkpoints

## Key Implementations

### Rails 8 Native (ActiveJob::Continuable)

```ruby
# app/jobs/rails_native/process_orders_job.rb
class RailsNative::ProcessOrdersJob < ApplicationJob
  include ActiveJob::Continuable
  include Interruptible

  def perform
    # Step 1: Load orders (runs once)
    step :load_orders do
      @order_ids = Order.pending.pluck(:id)
    end

    # Step 2: Process with checkpoints
    step :process_orders do |step|
      @order_ids.drop(step.cursor).each do |order_id|
        check_interruption_flag

        OrderProcessor.new(Order.find(order_id)).process!
        step.advance! from: step.cursor + 1
      end
    end

    # Step 3: Finalize (runs once)
    step :finalize do
      Notification.send_completion_alert
    end
  end
end
```

**Key APIs**:
- `step :name` - Define processing stage
- `step.cursor` - Current position
- `step.advance! from: position` - Update checkpoint

### Shopify job-iteration

```ruby
# app/jobs/job_iteration/process_orders_iteration_job.rb
class JobIteration::ProcessOrdersIterationJob < ApplicationJob
  include JobIteration::Iteration
  include Interruptible

  def build_enumerator(cursor:)
    enumerator_builder.active_record_on_records(
      Order.pending.order(:id),
      cursor: cursor
    )
  end

  def each_iteration(order)
    check_interruption_flag
    OrderProcessor.new(order).process!
    # Checkpoint happens automatically
  end

  def on_complete
    Notification.send_completion_alert
  end
end
```

**Key APIs**:
- `build_enumerator(cursor:)` - Return resumable enumerator
- `each_iteration(item)` - Process single item
- `enumerator_builder` - Helpers (active_record_on_records, nested, etc.)

## Interruption Strategy

### Four Methods for Different Use Cases:

1. **SIGTERM (Production-like)**
   ```bash
   # Most realistic
   kill -TERM <sidekiq_pid>
   ```

2. **Flag-based (Deterministic)**
   ```ruby
   # Set flag in Redis to interrupt at precise point
   rake demo:interrupt_at[order_id:300]
   ```

3. **Time-based (Demo-friendly)**
   ```ruby
   # Auto-interrupt after N seconds
   rake demo:run[rails_native:orders,interrupt_after:10]
   ```

4. **Progress-based (Testing)**
   ```ruby
   # Interrupt after exactly N items
   rake demo:interrupt_after_items[300]
   ```

## Data Seed Strategy

```ruby
# db/seeds.rb
# Quick mode (30 seconds):
#   - 50 customers
#   - 100 orders
#   - 1 email campaign (500 recipients)

# Full mode (5 minutes):
#   - 5,000 customers
#   - 10,000 orders
#   - 3 email campaigns (5000, 1000, 500 recipients)

# Use Faker for realistic data
# Include edge cases (nil values, errors)
# Pre-seed some interrupted job states for testing
```

## Real-time Monitoring

```ruby
# lib/demo/job_monitor.rb
# Terminal dashboard showing:
# - Progress bars for each job type
# - Current cursor position
# - Step information (Rails native)
# - Redis checkpoint state
# - Interruption count
# - Sidekiq queue status

rake demo:monitor  # Live updates every 1 second
```

## Demo Execution Flows

### Automated Demo (Presentations)
```bash
script/demo_rails_native
# 1. Starts Sidekiq worker
# 2. Enqueues job
# 3. Auto-interrupts after 10s
# 4. Shows checkpoint state
# 5. Resumes to completion
# 6. Shows comparison metrics
```

### Manual Demo (Learning)
```bash
# Terminal 1: Worker
bundle exec sidekiq -C config/sidekiq.yml

# Terminal 2: Monitor
rake demo:monitor

# Terminal 3: Control
rake demo:run[rails_native:orders]
# Wait ~10s, then Ctrl+C to interrupt
rake demo:show_checkpoint[rails_native:orders]
rake demo:resume[rails_native:orders]
```

### Comparison Demo (Architecture)
```bash
script/demo_comparison
# Runs both implementations side-by-side
# Shows performance metrics
# Highlights checkpoint differences
```

## Documentation Structure

### README.md (Quick Start - ~100 lines)
- Project overview and purpose
- Quick setup instructions (3-5 steps)
- How to run the demos
- Links to detailed documentation
- Troubleshooting basics

### plan.md (Implementation Plan - ~400 lines)
- Copy of the full implementation plan from Claude plan file
- Architecture decisions and rationale
- Project structure
- Implementation sequence
- Verification criteria
- Reference for understanding the project design

### agents.md (Comprehensive - ~500 lines)
- **Quick Start**: Prerequisites, setup, first run
- **Architecture Deep Dive**: How each pattern works
- **API Walkthrough**: Code examples with explanations
- **Demo Scenarios**: Step-by-step for each job type
- **Interruption Methods**: Detailed guide
- **Comparison Analysis**: Feature matrix, when to use each
- **Testing Strategies**: Unit, integration, smoke tests
- **Troubleshooting**: Common issues and solutions
- **Advanced Topics**: Nested iterations, error handling
- **Code References**: File paths with line numbers

### claude.md (AI Reference - ~150 lines)
- Project purpose
- Reference to agents.md for details
- Key files for code review
- Quick commands
- Modification guidelines

## Feature Comparison Matrix

| Feature | Rails 8 Native | job-iteration |
|---------|----------------|---------------|
| Setup | Built-in (Rails 8+) | Gem required |
| Checkpoint Storage | Job arguments | Redis |
| API Style | Step-based blocks | Enumerator pattern |
| Progress Tracking | Manual (step.advance!) | Automatic |
| Nested Iteration | Nested step blocks | nested() enumerator |
| Community | New (Rails 8) | Established (Shopify) |
| Best For | New Rails 8+ apps | Existing apps |

## Critical Files

**Documentation**:
- `/README.md` - Quick start guide (create first for easy onboarding)
- `/plan.md` - Implementation plan and architecture decisions
- `/agents.md` - Comprehensive developer guide (already created)
- `/claude.md` - AI agent reference (already created)

**Job Implementations**:
- `/app/jobs/rails_native/process_orders_job.rb` - Rails 8 Continuable implementation
- `/app/jobs/job_iteration/process_orders_iteration_job.rb` - job-iteration implementation
- `/app/jobs/rails_native/generate_reports_job.rb` - Nested iteration (Rails native)
- `/app/jobs/job_iteration/generate_reports_iteration_job.rb` - Nested iteration (job-iteration)

**Demo Infrastructure**:
- `/lib/demo/job_monitor.rb` - Real-time progress monitoring
- `/lib/demo/interruptor.rb` - Interruption simulation
- `/lib/tasks/demo.rake` - Demo orchestration

**Configuration & Data**:
- `/config/initializers/sidekiq.rb` - Sidekiq + Redis configuration
- `/db/seeds.rb` - Demo data generation

## Setup Steps

1. **Initialize Rails 8 app**
   ```bash
   rails new job-continuation-demo --skip-javascript --skip-hotwire
   cd job-continuation-demo
   ```

2. **Add dependencies to Gemfile**
   ```ruby
   gem 'sidekiq'
   gem 'job-iteration'
   gem 'faker'  # For realistic demo data
   gem 'redis'
   ```

3. **Create database migrations**
   - orders (customer_id, status, amount, processed_at)
   - customers (name, email, created_at)
   - email_campaigns (name, subject, status, sent_count)

4. **Implement Rails native jobs**
   - Include ActiveJob::Continuable
   - Use step blocks with cursor
   - Call step.advance! for checkpoints

5. **Implement job-iteration jobs**
   - Include JobIteration::Iteration
   - Define build_enumerator
   - Define each_iteration

6. **Create demo infrastructure**
   - Job monitor with progress bars
   - Interruptor for controlled interruption
   - Rake tasks for common operations

7. **Write seed data**
   - Generate realistic orders/customers
   - Include edge cases
   - Support quick/full modes

8. **Create demo scripts**
   - Setup script
   - Individual demo scripts
   - Comparison script

9. **Write documentation**
   - README.md (quick start guide)
   - plan.md (implementation plan copy)
   - agents.md (comprehensive developer guide)
   - claude.md (AI agent reference)

10. **Add tests**
    - Unit tests for each job
    - Integration tests for interruption/resumption
    - Smoke tests for setup verification

## Verification & Testing

### Setup Verification
```bash
script/setup
# Should complete with:
# ✅ Dependencies installed
# ✅ Database created
# ✅ Redis connected
# ✅ Demo data seeded
# ✅ Sidekiq configured
```

### Demo Verification
```bash
# Test Rails 8 native
script/demo_rails_native
# Expected: Job processes ~300 orders, interrupts, resumes, completes 1000

# Test job-iteration
script/demo_job_iteration
# Expected: Same behavior, different checkpoint mechanism

# Test comparison
script/demo_comparison
# Expected: Side-by-side metrics showing both complete successfully
```

### Manual Testing
```bash
# Start components
redis-server
bundle exec sidekiq -C config/sidekiq.yml

# In Rails console
RailsNative::ProcessOrdersJob.perform_later
# Interrupt with Ctrl+C after 10s
# Restart Sidekiq
# Job should resume from checkpoint

# Verify in Redis
redis-cli KEYS "sidekiq:*"
# Should see checkpoint data
```

### Interruption Testing
```bash
# Test each interruption method
rake demo:test_sigterm
rake demo:test_flag_based
rake demo:test_time_based
rake demo:test_progress_based

# Each should:
# - Start job
# - Interrupt at expected point
# - Save checkpoint correctly
# - Resume without duplicates
# - Complete successfully
```

### Edge Cases
```bash
# Multiple interruptions
rake demo:test_multiple_interruptions
# Expected: Job resumes correctly after 3+ interruptions

# Concurrent jobs
rake demo:test_concurrent
# Expected: No checkpoint conflicts, isolated progress

# Failed items
rake demo:test_with_failures[fail_rate:0.1]
# Expected: Errors handled, job continues
```

### Success Criteria
- ✅ Both implementations complete 1000 orders
- ✅ Jobs resume from exact checkpoint position
- ✅ No duplicate processing detected
- ✅ Monitoring shows real-time progress
- ✅ Interruption methods work reliably
- ✅ Documentation is clear and comprehensive
- ✅ All tests pass
- ✅ Demo scripts work without errors

## Implementation Sequence

1. **Phase 1**: Rails app scaffolding + dependencies
2. **Phase 2**: Database models and migrations
3. **Phase 3**: Rails native jobs (simple → complex)
4. **Phase 4**: job-iteration jobs (simple → complex)
5. **Phase 5**: Demo infrastructure (monitor, interruptor)
6. **Phase 6**: Seed data and rake tasks
7. **Phase 7**: Demo scripts
8. **Phase 8**: Documentation
   - README.md (quick start - create first)
   - plan.md (copy implementation plan to project directory)
   - agents.md (already created - comprehensive guide)
   - claude.md (already created - AI reference)
9. **Phase 9**: Testing and verification
10. **Phase 10**: Polish and final validation

## Notes

- Keep both implementations synchronized (same business logic)
- Prioritize clarity over optimization (educational demo)
- Include detailed logging for demonstration purposes
- Make interruption points obvious and controllable
- Focus on practical, realistic scenarios
- Ensure easy setup for presenters

---

**Plan Status**: Documentation Phase Complete ✅

**Next Steps**: Begin Phase 1 - Rails app scaffolding and dependencies

**Reference**: See `README.md` for quick start, `agents.md` for detailed implementation guidance

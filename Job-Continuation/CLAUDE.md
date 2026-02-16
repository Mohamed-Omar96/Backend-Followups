# Claude Code Context - Job Continuation Demo

## Project Overview

This repository contains educational demonstrations of job continuation patterns for Ruby on Rails background jobs.

**Purpose**: Show backend teams how to build resilient, interruptible background jobs that can resume from checkpoints.

## Two Patterns Demonstrated

1. **Rails 8 Native** (`ActiveJob::Continuable`) - Step-based continuation built into Rails 8
2. **Shopify job-iteration** - Enumerator-based pattern using the established gem

Both patterns solve the same problem: preventing progress loss when background jobs are interrupted (deployments, pod restarts, infrastructure issues).

## For Comprehensive Documentation

**See `agents.md`** for detailed information including:

- Architecture deep dive (how each pattern works)
- Setup and installation instructions
- Demo scenario walkthroughs
- Code examples with explanations
- Testing strategies
- Troubleshooting guide
- Comparison analysis
- Advanced topics (nested iterations, custom enumerators, error handling)

## Quick Reference

### Key Files for Code Review

**Rails 8 Native Jobs**:
- `app/jobs/rails_native/process_orders_job.rb` - Simple linear processing example
- `app/jobs/rails_native/generate_reports_job.rb` - Nested iteration (customers → orders)
- `app/jobs/rails_native/batch_email_job.rb` - Batch processing example

**job-iteration Jobs**:
- `app/jobs/job_iteration/process_orders_iteration_job.rb` - Simple enumerator example
- `app/jobs/job_iteration/generate_reports_iteration_job.rb` - Nested enumerator example
- `app/jobs/job_iteration/batch_email_iteration_job.rb` - Batch processing example

**Demo Infrastructure**:
- `lib/demo/job_monitor.rb` - Real-time progress monitoring dashboard
- `lib/demo/interruptor.rb` - Controlled interruption simulation
- `lib/demo/comparison_reporter.rb` - Side-by-side performance metrics
- `lib/tasks/demo.rake` - Rake tasks for running demos

**Configuration**:
- `config/initializers/sidekiq.rb` - Sidekiq + Redis setup
- `config/initializers/job_iteration.rb` - job-iteration configuration
- `config/sidekiq.yml` - Worker configuration (timeout, concurrency)

**Data**:
- `db/seeds.rb` - Demo data generation (orders, customers, email campaigns)
- `app/models/` - Order, Customer, EmailCampaign models

### Quick Commands

```bash
# Initial setup
script/setup

# Run demos
script/demo_rails_native        # Rails 8 native pattern
script/demo_job_iteration       # job-iteration pattern
script/demo_comparison          # Side-by-side comparison

# Manual control
bundle exec sidekiq -C config/sidekiq.yml    # Start worker
rake demo:monitor                            # Watch progress
rake 'demo:run[rails_native:orders]'        # Run specific job
rake 'demo:interrupt_at[order_id:300]'      # Interrupt at point
rake 'demo:show_checkpoint[job_name]'       # Show saved state

# Data management
rake demo:clean                # Clean all demo data (destroys records + clears Redis)
rake 'demo:seed[quick]'        # 100 orders (30 seconds)
rake 'demo:seed[full]'         # 10,000 orders (5 minutes)
rake db:reset                  # Complete database reset

# Reset orders to pending status (after seeding)
bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"

# Complete reset workflow (clean slate with all pending orders)
rake demo:clean && rake 'demo:seed[quick]' && bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"

# Testing
rake demo:verify               # Verify setup
rspec spec/jobs                # Unit tests
rspec spec/integration         # Integration tests
```

## Project Structure

```
job-continuation-demo/
├── app/jobs/
│   ├── rails_native/          # Rails 8 Continuable examples
│   ├── job_iteration/         # job-iteration examples
│   └── concerns/
│       └── interruptible.rb   # Shared interruption helpers
├── lib/
│   ├── demo/                  # Demo infrastructure
│   └── tasks/demo.rake        # Demo orchestration
├── script/
│   ├── setup                  # Initial setup
│   ├── demo_rails_native      # Automated Rails 8 demo
│   ├── demo_job_iteration     # Automated iteration demo
│   └── demo_comparison        # Comparison demo
├── agents.md                  # Comprehensive guide (read this!)
├── claude.md                  # This file
└── README.md                  # Quick start guide
```

## Scenario: E-commerce Order Processing

The demos use a realistic e-commerce scenario with three jobs:

1. **Process Orders** (Simple): 1000 orders, linear processing
2. **Generate Reports** (Nested): 100 customers × 50 orders each
3. **Batch Emails** (Complex): 5000 recipients in batches of 50

Each demonstrates interruption at different points and successful resumption from checkpoints.

## Key Concepts

### Rails 8 Native Pattern
```ruby
include ActiveJob::Continuable

step :process_orders do |step|
  orders.drop(step.cursor).each do |order|
    process(order)
    step.advance! from: step.cursor + 1  # Save checkpoint
  end
end
```

**Checkpoint stored in**: Job arguments (database)
**API style**: Step-based blocks with explicit cursor management

### job-iteration Pattern
```ruby
include JobIteration::Iteration

def build_enumerator(cursor:)
  enumerator_builder.active_record_on_records(
    Order.pending,
    cursor: cursor
  )
end

def each_iteration(order)
  process(order)
  # Checkpoint saved automatically
end
```

**Checkpoint stored in**: Redis
**API style**: Enumerator pattern with automatic cursor tracking

## When Modifying Code

1. **Keep implementations synchronized**: Both patterns should implement the same business logic for fair comparison
2. **Update documentation**: If you change architecture or patterns, update `agents.md`
3. **Maintain demo scripts**: Ensure automated demos still work after changes
4. **Test interruption scenarios**: Verify checkpoints save and resume correctly
5. **Preserve educational value**: Code should be clear and well-commented for demos

## Common Modifications

### Adding a New Job Example

1. Create Rails native version: `app/jobs/rails_native/my_job.rb`
2. Create job-iteration version: `app/jobs/job_iteration/my_iteration_job.rb`
3. Add demo task: `lib/tasks/demo.rake` (add `demo:run[my_job]` task)
4. Add to demo script: Update `script/demo_comparison` to include new job
5. Document in `agents.md`: Add scenario description and code walkthrough

### Changing Demo Data

1. Modify seed file: `db/seeds.rb`
2. Update quantities in plan: `/Users/mohamedomarwork/.claude/plans/tranquil-floating-rossum.md`
3. Adjust interruption timing: Update `script/demo_*` files if needed
4. Update documentation: Reflect new data volumes in `agents.md`

### Adjusting Interruption Methods

1. Core logic: `app/jobs/concerns/interruptible.rb`
2. Interruptor: `lib/demo/interruptor.rb`
3. Demo tasks: `lib/tasks/demo.rake` (add new interruption rake tasks)
4. Document method: Add to "Interruption Methods" section in `agents.md`

## Testing Philosophy

- **Unit tests**: Verify individual job logic (processing, error handling)
- **Integration tests**: Verify interruption and resumption flow
- **Smoke tests**: Verify demo setup (Redis, Sidekiq, database)
- **Manual tests**: Run demo scripts to ensure smooth presentation flow

## For AI Agents

When working with this codebase:

1. **Reference `agents.md` first** for architecture understanding
2. **Keep both patterns in sync** when making changes to job logic
3. **Test both approaches** after modifications
4. **Preserve demo-ability** - code should be presentable and clear
5. **Maintain educational comments** - this is teaching material
6. **Update plan file** at `/Users/mohamedomarwork/.claude/plans/tranquil-floating-rossum.md` for major changes

## Questions or Issues?

1. Check `agents.md` - Troubleshooting section
2. Check `agents.md` - Advanced Topics for complex scenarios
3. Review demo scripts in `script/` directory
4. Inspect rake tasks in `lib/tasks/demo.rake`

---

**Quick Start**: Run `script/setup` then `script/demo_rails_native`

**Full Guide**: Read `agents.md`

**Plan Reference**: `/Users/mohamedomarwork/.claude/plans/tranquil-floating-rossum.md`

---

*Last Updated: 2026-02-02*
*Demo Version: 1.0.0*

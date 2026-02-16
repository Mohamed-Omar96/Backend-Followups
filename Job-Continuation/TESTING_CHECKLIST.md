# Testing Checklist for Job Continuation Demo

Use this checklist to verify everything works before presenting to others.

## Pre-Flight Checks

### 1. Environment Setup
```bash
# Check Ruby version
ruby --version
# Expected: ruby 3.3.6 or higher

# Check Rails version
bundle exec rails --version
# Expected: Rails 8.1.2 or higher

# Check Redis
redis-cli ping
# Expected: PONG
```

- [ ] Ruby 3.3.6+ installed
- [ ] Rails 8.1.2+ available
- [ ] Redis running and responding

### 2. Install Dependencies
```bash
bundle install
```

- [ ] All gems installed successfully
- [ ] No version conflicts

### 3. Database Setup
```bash
bundle exec rails db:create
bundle exec rails db:migrate
SEED_MODE=quick bundle exec rails db:seed
```

- [ ] Development database created
- [ ] Test database created
- [ ] Migrations ran successfully
- [ ] Seed data loaded (50 customers, 100 orders, 1 campaign)

### 4. Verification
```bash
bundle exec rake demo:verify
```

- [ ] All checks pass with green ✓
- [ ] Redis connection successful
- [ ] Seed data present

## Test Suite Verification

### Run All Tests
```bash
bundle exec rspec
```

**Expected Result:**
```
38 examples, 0 failures
Finished in ~1 second
```

- [ ] All 38 tests pass
- [ ] No failures
- [ ] No errors
- [ ] Completes in under 2 seconds

### Run Test Suites Individually

```bash
# Model tests (21 examples)
bundle exec rspec spec/models
```
- [ ] 21 examples, 0 failures

```bash
# Service tests (2 examples)
bundle exec rspec spec/services
```
- [ ] 2 examples, 0 failures

```bash
# Job tests (9 examples)
bundle exec rspec spec/jobs
```
- [ ] 9 examples, 0 failures

```bash
# Integration tests (6 examples)
bundle exec rspec spec/integration
```
- [ ] 6 examples, 0 failures

## Demo Testing

### Demo 1: Automated Rails Native

```bash
./script/demo_rails_native
```

**What to verify:**
- [ ] Script starts without errors
- [ ] Sidekiq starts automatically
- [ ] Job processes orders (watch for log output)
- [ ] After ~10 seconds, interruption occurs
- [ ] Checkpoint state displayed showing cursor position
- [ ] Worker restarts automatically
- [ ] Job resumes from checkpoint
- [ ] Final statistics show all orders processed
- [ ] No duplicate processing

**Expected output includes:**
```
✓ Sidekiq started
✓ Reset 61 pending orders
✓ Job enqueued
⚠️  Simulating interruption (SIGTERM)...
Checkpoint state after interruption:
  Step: process_orders
  Cursor: [some number]
✓ Worker restarted
✅ Job completed with checkpoint recovery!
```

### Demo 2: Manual Demo (3 Terminals)

**Terminal 1: Start Sidekiq**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```
- [ ] Sidekiq starts successfully
- [ ] Shows "Sidekiq 7.x connecting to Redis"
- [ ] No error messages

**Terminal 2: Monitor Progress**
```bash
bundle exec rake demo:monitor
```
- [ ] Monitor starts successfully
- [ ] Shows order processing stats
- [ ] Progress bar visible
- [ ] Updates every second

**Terminal 3: Enqueue Job**
```bash
bundle exec rake demo:run[rails_native:orders]
```
- [ ] Job enqueued successfully
- [ ] See activity in Terminal 1 (Sidekiq logs)
- [ ] See progress in Terminal 2 (Monitor)

**Interrupt and Resume:**
- [ ] After 10 seconds, press Ctrl+C in Terminal 1
- [ ] Sidekiq shuts down gracefully
- [ ] Check checkpoint: `bundle exec rake demo:show_checkpoints`
- [ ] Restart Sidekiq in Terminal 1
- [ ] Watch job resume in Terminal 2
- [ ] All orders eventually processed

### Demo 3: job-iteration Demo

```bash
./script/demo_job_iteration
```

- [ ] Similar flow to Rails Native demo
- [ ] Uses job-iteration pattern
- [ ] Checkpoints stored in Redis
- [ ] Resumes correctly after interruption

### Demo 4: Comparison Demo

```bash
./script/demo_comparison
```

- [ ] Runs both patterns sequentially
- [ ] Shows performance comparison table
- [ ] Displays checkpoint differences
- [ ] Provides recommendations
- [ ] Completes without errors

## Manual Testing Scenarios

### Scenario 1: Check Monitoring Dashboard

```bash
# Terminal 1: Start monitor
bundle exec rake demo:monitor

# Terminal 2: Start Sidekiq
bundle exec sidekiq -C config/sidekiq.yml

# Terminal 3: Run job
bundle exec rake demo:run[rails_native:orders]
```

**Verify:**
- [ ] Monitor shows real-time updates
- [ ] Progress bar animates
- [ ] Order counts change
- [ ] Sidekiq stats update
- [ ] Pressing Ctrl+C stops monitor cleanly

### Scenario 2: Test Checkpoint State

```bash
# Start Sidekiq
bundle exec sidekiq -C config/sidekiq.yml &

# Enqueue job
bundle exec rake demo:run[rails_native:orders]

# Wait 5 seconds then interrupt
bundle exec rake demo:interrupt

# Check checkpoints
bundle exec rake demo:show_checkpoints
```

**Verify:**
- [ ] Checkpoint state shows cursor position
- [ ] For Rails Native: Shows step and cursor
- [ ] For job-iteration: Shows Redis keys and cursors
- [ ] Cursor value is reasonable (> 0, < total orders)

### Scenario 3: Test All Job Types

```bash
# Start Sidekiq
bundle exec sidekiq -C config/sidekiq.yml

# Test each job type
bundle exec rake demo:run[rails_native:orders]
# Wait for completion
bundle exec rake demo:run[rails_native:reports]
# Wait for completion
bundle exec rake demo:run[rails_native:emails]
# Wait for completion
bundle exec rake demo:run[job_iteration:orders]
# Wait for completion
```

**Verify:**
- [ ] All jobs enqueue successfully
- [ ] All jobs process without errors
- [ ] Each job completes its work
- [ ] No exceptions in Sidekiq logs

## Edge Cases & Error Scenarios

### Test 1: Redis Down During Job

```bash
# Start job
bundle exec sidekiq -C config/sidekiq.yml &
bundle exec rake demo:run[job_iteration:orders]

# Stop Redis (in another terminal)
# redis-cli shutdown

# Wait and observe
```

**Expected behavior:**
- [ ] Job fails gracefully (for job-iteration)
- [ ] Error logged appropriately
- [ ] No crash or hang

**Cleanup:**
```bash
redis-server &
```

### Test 2: Multiple Interruptions

```bash
# Start job
bundle exec rake demo:run[rails_native:orders]

# Interrupt multiple times
# Each time: Ctrl+C Sidekiq, restart it
```

**Verify:**
- [ ] Job resumes correctly each time
- [ ] Cursor advances properly
- [ ] Eventually completes all orders
- [ ] No duplicate processing

### Test 3: Empty Queue

```bash
# With no pending orders
bundle exec rails runner "Order.update_all(status: 'processed')"
bundle exec rake demo:run[rails_native:orders]
```

**Verify:**
- [ ] Job completes immediately
- [ ] No errors
- [ ] Logs show 0 orders processed

## Data Integrity Checks

### Check for Duplicate Processing

```bash
bundle exec rails runner "
  Order.group(:id).having('COUNT(*) > 1').count.each do |id, count|
    puts \"Order \#{id} processed \#{count} times\"
  end
  puts 'No duplicates found' if Order.group(:id).having('COUNT(*) > 1').count.empty?
"
```

- [ ] No duplicate processing detected
- [ ] Each order processed exactly once

### Check Final States

```bash
bundle exec rails runner "
  puts 'Total orders: ' + Order.count.to_s
  puts 'Pending: ' + Order.pending.count.to_s
  puts 'Processed: ' + Order.processed.count.to_s
  puts 'Failed: ' + Order.failed.count.to_s
"
```

- [ ] All pending orders eventually processed
- [ ] Numbers add up correctly

## Performance Checks

### Monitor Resource Usage

```bash
# In one terminal, monitor resources
watch -n 1 "ps aux | grep -E 'sidekiq|redis' | grep -v grep"

# In another, run job
bundle exec rake demo:run[rails_native:orders]
```

**Verify:**
- [ ] Memory usage reasonable (< 500MB)
- [ ] CPU usage reasonable (< 50% per core)
- [ ] No memory leaks
- [ ] Process completes and releases resources

## Cleanup and Reset

### Between Tests

```bash
# Reset to clean state
bundle exec rake demo:clean
SEED_MODE=quick bundle exec rails db:seed
```

- [ ] All data cleaned
- [ ] Fresh data seeded
- [ ] Ready for next test

### Complete Reset

```bash
bundle exec rails db:reset
SEED_MODE=quick bundle exec rails db:seed
```

- [ ] Database dropped and recreated
- [ ] Migrations rerun
- [ ] Data reseeded

## Pre-Presentation Checklist

Before showing to others:

- [ ] Ran all tests successfully (38 passing)
- [ ] Ran automated Rails Native demo successfully
- [ ] Ran automated job-iteration demo successfully
- [ ] Ran comparison demo successfully
- [ ] Verified Redis is running
- [ ] Have 3 terminals ready if doing manual demo
- [ ] Practiced explanation of checkpoints
- [ ] Know how to show checkpoint state
- [ ] Can explain difference between patterns
- [ ] Have backup plan if Redis not available

## Common Issues & Solutions

### Issue: Redis not running
```bash
brew services start redis  # macOS
sudo systemctl start redis # Linux
```

### Issue: Port already in use
```bash
# Find and kill process using port
lsof -ti:6379 | xargs kill -9
redis-server
```

### Issue: Sidekiq hangs
```bash
# Kill all Sidekiq processes
pkill -9 -f sidekiq
```

### Issue: Database locked
```bash
# Reset database
bundle exec rails db:reset
SEED_MODE=quick bundle exec rails db:seed
```

## Success Criteria

You're ready to present when:

✅ All 38 tests pass
✅ All 4 demo scripts work
✅ Monitoring dashboard displays correctly
✅ Interruption and resumption work reliably
✅ No duplicate processing occurs
✅ Checkpoint state visible and correct
✅ Both patterns (Rails Native and job-iteration) work
✅ Resource usage is reasonable
✅ Can explain the differences between patterns

## Quick Smoke Test (2 minutes)

Before any presentation, run this quick smoke test:

```bash
# 1. Verify setup
bundle exec rake demo:verify

# 2. Run tests
bundle exec rspec

# 3. Quick demo
./script/demo_rails_native

# All should complete successfully
```

If all three pass, you're good to go! 🚀

---

**Last tested:** [Add date when you verify]
**Tested by:** [Add your name]
**All checks passed:** [ ] Yes [ ] No

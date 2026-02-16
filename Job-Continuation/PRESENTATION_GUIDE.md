# Presentation Guide for Job Continuation Demo

This guide helps you present the Job Continuation Demo effectively to different audiences.

## Quick Reference Card

Keep this handy during presentations:

**Start Redis:** `redis-server` or `brew services start redis`
**Run Tests:** `bundle exec rspec`
**Quick Demo:** `./script/demo_rails_native`
**Manual Demo:** 3 terminals (Sidekiq, Monitor, Commands)
**Comparison:** `./script/demo_comparison`

## Presentation Formats

### Format 1: Executive Summary (5 minutes)

**Audience:** Engineering managers, product managers
**Goal:** Show business value

**Script:**
1. **Problem** (1 min): "When processing millions of records, server restarts lose all progress. This costs time and money."

2. **Solution** (2 min): "Job continuation saves checkpoints. On restart, jobs resume exactly where they stopped."

3. **Demo** (2 min):
   ```bash
   ./script/demo_rails_native
   ```
   Point out:
   - Job starts processing
   - Interruption occurs
   - Job resumes from checkpoint
   - No duplicate processing

4. **Value:** "Prevents wasted computation, faster deployments, better resource utilization."

### Format 2: Technical Deep Dive (15 minutes)

**Audience:** Engineers
**Goal:** Explain implementation

**Structure:**

1. **Introduction** (2 min)
   - Show the problem with traditional jobs
   - Introduce two patterns

2. **Code Walkthrough** (5 min)
   - Open `app/jobs/rails_native/process_orders_job.rb`
   - Explain `step` blocks and `step.advance!`
   - Show cursor tracking
   - Compare with `app/jobs/job_iteration/process_orders_iteration_job.rb`
   - Explain enumerator pattern

3. **Live Demo** (5 min)
   - **Terminal 1:** `bundle exec sidekiq -C config/sidekiq.yml`
   - **Terminal 2:** `bundle exec rake demo:monitor`
   - **Terminal 3:** `bundle exec rake demo:run[rails_native:orders]`
   - After 10 seconds, Ctrl+C Terminal 1
   - Show checkpoint: `bundle exec rake demo:show_checkpoints`
   - Restart Sidekiq, watch resume

4. **Q&A** (3 min)

### Format 3: Architecture Review (30 minutes)

**Audience:** Senior engineers, architects
**Goal:** Deep technical understanding

**Agenda:**

1. **Context** (3 min)
   - Cloud-native challenges
   - Kubernetes pod evictions
   - Deployment strategies

2. **Pattern Comparison** (7 min)
   ```bash
   ./script/demo_comparison
   ```
   - Discuss trade-offs
   - Checkpoint storage differences
   - Performance implications
   - When to use each

3. **Nested Iteration** (5 min)
   - Show `generate_reports_job.rb`
   - Explain multi-level checkpoints
   - Demo nested scenario

4. **Error Handling** (5 min)
   - Show service classes
   - Discuss retry strategies
   - Failure scenarios

5. **Testing Strategy** (5 min)
   ```bash
   bundle exec rspec --format documentation
   ```
   - Show test coverage
   - Explain interruption testing
   - Integration tests

6. **Production Considerations** (5 min)
   - Monitoring
   - Alerting
   - Checkpoint cleanup
   - Scale considerations

## Demo Scripts

### Script A: "The Happy Path"

Show everything working smoothly.

```bash
# Setup (before presentation)
bundle exec rake demo:verify
SEED_MODE=quick bundle exec rails db:seed

# During presentation
./script/demo_rails_native
```

**Narration:**
- "This job processes 61 pending orders"
- "Watch the progress... it's processing successfully"
- "Now we'll simulate a deployment - SIGTERM sent"
- "Notice the checkpoint saved at order 23"
- "Worker restarting... and it picks up at order 24"
- "No duplicates, no lost progress"

### Script B: "Manual Control"

Show the internals and give audience control.

**Terminal Setup:**
```
Terminal 1 (Left):   Sidekiq logs
Terminal 2 (Right):  Monitor dashboard
Terminal 3 (Bottom): Commands
```

**Walkthrough:**
```bash
# Terminal 1
bundle exec sidekiq -C config/sidekiq.yml

# Terminal 2
bundle exec rake demo:monitor

# Terminal 3
bundle exec rake demo:run[rails_native:orders]
```

**Interactive moments:**
- "You can see Sidekiq processing in terminal 1"
- "The monitor shows real-time progress"
- "Let's interrupt it now..." (Ctrl+C Terminal 1)
- "Let's check the checkpoint state..."
- "And resume..." (restart Sidekiq)

### Script C: "Comparison Analysis"

Show both patterns side-by-side.

```bash
./script/demo_comparison
```

**Discussion points:**
- Checkpoint storage differences
- API style preferences
- Performance characteristics
- Production maturity
- When to choose each

## Handling Questions

### Q: "What happens if Redis goes down?"

**Answer:**
- For job-iteration: Job fails, will retry on next attempt
- Checkpoints are transient, job restarts from beginning if lost
- Production: Use Redis Sentinel or Redis Cluster for HA
- Show in AGENTS.md: Troubleshooting section

### Q: "How does this handle errors in individual items?"

**Answer:**
- Show `order_processor.rb` with error handling
- Explain: Can skip failed items and continue
- Or: Can fail entire job for critical errors
- Job-level retries still available

### Q: "What's the overhead of checkpointing?"

**Answer:**
- Rails Native: ~5-10ms per checkpoint (DB write)
- job-iteration: ~1-2ms per checkpoint (Redis write)
- Can adjust checkpoint frequency for performance
- Show batch processing example

### Q: "Can this work with Kubernetes?"

**Answer:**
- Yes! That's the main use case
- SIGTERM from K8s triggers graceful shutdown
- Pod can be rescheduled immediately
- Job resumes when picked up by new pod

### Q: "How do you test this in CI?"

**Answer:**
```bash
bundle exec rspec spec/integration
```
- Show integration tests
- Explain interruption simulation
- Mention test helpers

## Common Pitfalls

### Pitfall 1: Redis Not Running

**Prevention:**
- Check Redis before starting: `redis-cli ping`
- Have backup: show verification first

**Recovery:**
```bash
brew services start redis
# Or
redis-server &
```

### Pitfall 2: Sidekiq Doesn't Stop

**Prevention:**
- Use Ctrl+C (sends SIGTERM)
- Wait for graceful shutdown

**Recovery:**
```bash
pkill -9 -f sidekiq
```

### Pitfall 3: No Pending Orders or Mixed Status Orders

**Prevention:**
- Seed before demo
- Reset orders to pending status
- Verify with `rake demo:snapshot`

**Recovery:**
```bash
# Complete reset workflow
bundle exec rake demo:clean
bundle exec rake 'demo:seed[quick]'
bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"

# Verify all orders are pending
bundle exec rake demo:snapshot
# Should show: Total: 100 | Pending: 100 | Processed: 0 | Failed: 0
```

**Note:** The seed file intentionally creates orders with mixed statuses (60% pending, some processed, some failed) to simulate realistic scenarios. For clean demo runs where you want to process all orders from scratch, you must reset them to pending after seeding.

## Visual Aids

### Checkpoint Flow Diagram

Draw this on whiteboard:

```
Start Job → Process Item 1 → Save Checkpoint (cursor: 1)
         → Process Item 2 → Save Checkpoint (cursor: 2)
         → Process Item 3 → Save Checkpoint (cursor: 3)
         → [INTERRUPTION - SIGTERM]
         → Job Re-enqueued with cursor: 3
         → Resume Job from Item 4 →
         → Process Item 4 → ...
```

### Pattern Comparison Table

Show on screen:

| Feature | Rails 8 Native | job-iteration |
|---------|----------------|---------------|
| Setup | Built-in | Gem required |
| Storage | Job args (DB) | Redis |
| API | Step blocks | Enumerators |
| Maturity | New (2025) | Battle-tested |

## Post-Presentation

### Follow-Up Materials

Share with attendees:
- **README.md** - Setup instructions
- **AGENTS.md** - Deep dive documentation
- **TESTING_CHECKLIST.md** - Verification steps
- Repository link

### Feedback Collection

Ask:
- "Which pattern would you use?"
- "Any concerns about production use?"
- "What other use cases come to mind?"

## Troubleshooting During Presentation

### If demo fails:

1. **Stay calm** - "Let's check the setup"
2. **Run verification:** `bundle exec rake demo:verify`
3. **Check basics:** Redis, Sidekiq, data
4. **Have backup:** Show tests passing instead
5. **Explain concept:** Code walkthrough if demo broken

### Backup Plan

If live demo fails completely:

1. Show test suite running: `bundle exec rspec --format documentation`
2. Walk through code in `app/jobs/`
3. Show AGENTS.md architecture section
4. Explain conceptually with diagrams

## Success Metrics

You nailed the presentation if:

✅ Audience understands the problem
✅ Live demo worked (or backup succeeded)
✅ Showed both patterns clearly
✅ Handled Q&A confidently
✅ Code examples were clear
✅ Attendees know when to use each pattern

## Time Estimates

- **5-min version:** Problem + Quick demo + Value
- **15-min version:** + Code walkthrough + Live demo + Q&A
- **30-min version:** + Comparison + Nested example + Testing + Production discussion

Choose based on your time slot!

---

**Good luck with your presentation! 🎤**

Need help? Check AGENTS.md for detailed technical information.

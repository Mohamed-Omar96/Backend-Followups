# Rails 8+ Backend Follow-Up Demos

A collection of production-ready educational demonstrations for backend teams, covering three distinct Rails 8+ features through working code, live demos, and companion videos.

---

## Projects

### 1. Job Continuation (`Job-Continuation/`)

**Resilient background jobs that survive interruption.**

Demonstrates two side-by-side approaches to building jobs that can be safely stopped mid-run and resumed from a checkpoint — critical for cloud environments with rolling deployments and pod evictions.

| | Rails 8 Native | Shopify job-iteration |
|---|---|---|
| **API** | Step-based blocks | Enumerator pattern |
| **Checkpoint storage** | Job arguments (DB) | Redis |
| **Maturity** | Built into Rails 8 | Battle-tested at scale |

**Demo scenario**: E-commerce order processing (1,000 orders), nested customer/order report generation (100 × 50), and batch email campaigns (5,000 recipients).

**Tech**: Rails 8.1.1, Ruby 3.3.6, Sidekiq, Redis, RSpec

```bash
cd Job-Continuation
script/setup
script/demo_comparison    # side-by-side live demo
```

---

### 2. Local CI (`Local CI/`)

**The same CI suite runs locally and on GitHub Actions — no duplication.**

Rails 8.1 introduced `ActiveSupport::ContinuousIntegration`, a DSL for defining CI workflows in `config/ci.rb`. Running `./bin/ci` locally executes the exact same steps as the cloud CI pipeline.

```ruby
# config/ci.rb
CI.run do
  step "Setup",         "bin/rails db:test:prepare"
  step "Tests: Rails",  "bin/rails test"
  step "Style: Ruby",   "bin/rubocop" if File.exist?("bin/rubocop")
  step "Security",      "bin/brakeman --no-pager" if Dir.exist?("app")
end
```

**Tech**: Rails 8.1.2, Ruby 3.4.2, Minitest, RuboCop, Brakeman, Bundler Audit

```bash
cd "Local CI"
bin/setup --skip-server
./bin/ci                  # full CI suite
```

---

### 3. Structured Event Reporting (`Structured-Event-Reporting/`)

**The evolution from string logs to queryable structured events — across 3 live Rails apps.**

Three identical e-commerce APIs running simultaneously on different ports, differing only in how they emit observability data. The contrast makes the value of structured events immediately visible.

| Port | Project | Logging Approach |
|---|---|---|
| 3000 | `rails-8-0-traditional/` | `Rails.logger` with string interpolation (anti-patterns) |
| 3001 | `rails-8-1-traditional/` | `Rails.logger` on Rails 8.1 (backward compatible) |
| 3002 | `rails-8-1-structured/` | `Rails.event` with structured JSON subscribers |

**Key difference in action**:

```ruby
# Traditional (rails-8-0-traditional) — hard to query
Rails.logger.info "Order #{order.id} placed by user #{user.id} for $#{order.total}"

# Structured (rails-8-1-structured) — machine-readable, filterable
Rails.event.emit("order.placed", order_id: order.id, user_id: user.id, total: order.total)
```

**Tech**: Rails 8.0 / 8.1, Ruby 3.3+, JWT, BCrypt, AWS CloudWatch SDK, RSpec

```bash
cd Structured-Event-Reporting
./scripts/setup_all.sh
./scripts/start_all.sh         # ports 3000, 3001, 3002

# Watch structured events live
tail -f rails-8-1-structured/log/events-development.json | jq -C '.'
```

---

## Prerequisites

| Requirement | Job-Continuation | Local CI | Structured-Event-Reporting |
|---|:---:|:---:|:---:|
| Ruby 3.3+ | ✅ | | ✅ |
| Ruby 3.4+ | | ✅ | |
| Redis | ✅ | | |
| SQLite3 | ✅ | ✅ | ✅ |
| `jq` (optional) | | | ✅ |

**Install Redis (macOS):**
```bash
brew install redis && brew services start redis
redis-cli ping   # should return PONG
```

---

## Repository Layout

```
Backend-followup/
├── Job-Continuation/          # Rails 8.1 background job patterns
│   ├── app/jobs/
│   │   ├── rails_native/      # ActiveJob::Continuable examples
│   │   └── job_iteration/     # Shopify gem examples
│   ├── lib/demo/              # monitoring + interruption infrastructure
│   └── script/                # automated demo scripts
│
├── Local CI/                  # Rails 8.1 Local CI feature
│   ├── config/ci.rb           # CI workflow DSL
│   ├── bin/ci                 # CI runner
│   └── video/                 # Remotion companion video
│
└── Structured-Event-Reporting/
    ├── rails-8-0-traditional/ # Rails.logger anti-patterns (port 3000)
    ├── rails-8-1-traditional/ # Rails.logger on 8.1 (port 3001)
    ├── rails-8-1-structured/  # Rails.event reference impl (port 3002)
    ├── docs/                  # Shared presentation docs
    ├── scripts/               # Cross-project automation
    └── video/                 # Remotion companion video (bun)
```

---

## For AI Agents

See [`AGENTS.md`](AGENTS.md) for agent-specific rules — particularly the cross-project constraints that apply to all three demos (intentional anti-patterns, job sync requirements, and what not to change).

Each sub-project also has its own `AGENTS.md` with detailed patterns and conventions specific to that project.

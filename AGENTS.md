# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Cursor, GitHub Copilot, etc.) working in this repository.

## Repository Structure

This repository contains **3 independent educational Rails demo projects** and associated Remotion video sub-projects. There is no shared application code across the top-level projects.

| Directory | Rails Version | Ruby | Primary Feature |
|---|---|---|---|
| `Job-Continuation/` | 8.1.1 | 3.3.6 | `ActiveJob::Continuable` vs `job-iteration` |
| `Local CI/` | 8.1.2 | 3.4.2 | `bin/ci` + `config/ci.rb` Local CI DSL |
| `Structured-Event-Reporting/` | 8.0 / 8.1 | 3.3+ | `Rails.logger` → `Rails.event` evolution |

Each project is fully self-contained with its own Gemfile, database, and test suite. **Read the project-specific `AGENTS.md` before working inside any sub-directory** — all three have their own.

---

## Universal Rules Across All Projects

### 1. Anti-patterns are intentional

In `Structured-Event-Reporting`, the two traditional projects (`rails-8-0-traditional/`, `rails-8-1-traditional/`) intentionally contain bad patterns:
- Inconsistent log formats
- `Time.now` instead of `Time.current`
- `Thread.current` for context propagation
- String-interpolated log messages

**Do not fix these.** They are the educational contrast point. Only `rails-8-1-structured/` is the "correct" reference implementation.

### 2. Both job patterns must stay in sync

In `Job-Continuation/`, every business operation has two implementations:
- `app/jobs/rails_native/` — Rails 8 native pattern
- `app/jobs/job_iteration/` — Shopify gem pattern

When changing a job's business logic, update **both**. They must implement the same behavior.

### 3. Business logic is identical across all Structured-Event-Reporting projects

The three Structured-Event-Reporting apps share the same e-commerce domain (User, Product, Order, OrderItem, Payment) with identical API behavior. **Only the logging/event approach differs.** If you change an API response shape or model validation, propagate it to all three.

### 4. Never add `Rails.event` to the traditional projects

`Rails.event` is exclusively for `rails-8-1-structured/`. Its presence in the traditional projects would destroy the educational comparison.

### 5. This is teaching material, not production code

- Keep code readable over clever
- Preserve educational comments in jobs and subscribers
- Do not add features outside each project's demonstrated scope
- Do not add dependencies unless the feature being demonstrated requires them

---

## Common Task Patterns

### Making a change in one project only

```bash
cd Job-Continuation        # or "Local CI" or "Structured-Event-Reporting"
# make changes
bundle exec rspec          # Job-Continuation, Structured-Event-Reporting
./bin/ci                   # Local CI only
```

### Making a change across all three Structured-Event-Reporting projects

1. Implement the anti-pattern version in `rails-8-0-traditional/`
2. Copy the same code to `rails-8-1-traditional/`
3. Implement the `Rails.event` version in `rails-8-1-structured/`
4. Update `Structured-Event-Reporting/docs/COMPARISON.md`
5. Run `./scripts/verify_all.sh` from within `Structured-Event-Reporting/`

### Running a single spec file

```bash
# Job-Continuation
cd Job-Continuation && bundle exec rspec spec/jobs/rails_native/process_orders_job_spec.rb

# Structured-Event-Reporting (any sub-project)
cd Structured-Event-Reporting/rails-8-1-structured && bundle exec rspec spec/services/authentication_service_spec.rb

# Local CI
cd "Local CI" && bin/rails test test/models/article_test.rb:15
```

### Resetting demo state (Job-Continuation)

```bash
cd Job-Continuation
rake demo:clean && rake 'demo:seed[quick]'
bundle exec rails runner "Order.update_all(status: 'pending', processed_at: nil)"
```

### Port conflict resolution (Structured-Event-Reporting)

```bash
lsof -i :3000 && lsof -i :3001 && lsof -i :3002
./scripts/stop_all.sh    # from within Structured-Event-Reporting/
```

---

## Project-Specific Agent Guidance

### Job-Continuation

- Full architecture guide: `Job-Continuation/AGENTS.md` (42KB — comprehensive)
- **zsh gotcha**: rake tasks with square brackets require quoting: `rake 'demo:run[rails_native:orders]'`
- After any job change, run both `rspec spec/jobs` and `rspec spec/integration`
- Redis must be running before any Sidekiq or job-iteration test

### Local CI

- Full agent guide: `Local CI/AGENTS.md`
- **`./bin/ci` is mandatory** before marking any task complete — it runs tests, RuboCop, Bundler Audit, and Brakeman
- Test framework is Minitest (not RSpec) — do not introduce RSpec syntax
- Learning exercises in `test/models/article_test.rb` are intentionally commented out; do not uncomment them unless the user asks

### Structured-Event-Reporting

- Full agent guide: `Structured-Event-Reporting/AGENTS.md` plus each sub-project's own `AGENTS.md`
- `Rails.event` API reference: `Structured-Event-Reporting/rails-8-1-structured/AGENTS.md`
- Subscribers run synchronously in the request cycle — never add I/O or slow operations to a subscriber; queue to background jobs instead
- Event names are considered immutable once in use (consumers depend on them)

### Video Sub-Projects

- `Structured-Event-Reporting/video/AGENTS.md` and `Local CI/video/AGENTS.md`
- Package manager is `bun`, not npm or yarn — always use `bun install`, `bun run`, etc.
- All animations must use `useCurrentFrame()` + Remotion's `interpolate()` / `spring()` — never CSS transitions or `setTimeout`
- Do not apply Ruby/Rails conventions in video directories

---

## Documentation Map

Each project's documentation hierarchy:

```
Job-Continuation/
├── AGENTS.md          ← comprehensive developer guide
├── CLAUDE.md          ← AI agent quick reference
└── README.md          ← human quick start

Local CI/
├── AGENTS.md          ← AI agent patterns and conventions
├── CLAUDE.md          ← AI agent quick reference
├── README.md          ← human quick start
├── LOCAL_CI_GUIDE.md  ← DSL teaching guide
└── CODE_REVIEW.md     ← code review workflow

Structured-Event-Reporting/
├── AGENTS.md          ← cross-project agent rules
├── CLAUDE.md          ← cross-project quick reference
├── docs/
│   ├── COMPARISON.md       ← side-by-side code diffs
│   ├── ARCHITECTURE.md     ← Rails.event deep dive
│   ├── MIGRATION_GUIDE.md  ← upgrade path guide
│   ├── DEMO_SCRIPT.md      ← 60-min live demo script
│   └── PRESENTER_NOTES.md  ← Q&A prep
├── rails-8-0-traditional/AGENTS.md
├── rails-8-1-traditional/AGENTS.md
└── rails-8-1-structured/AGENTS.md   ← Rails.event patterns
```

---

## What NOT to Do

- **Do not run `bundle install` inside any `video/` directory** — they use `bun`
- **Do not run `bin/rails` or `rake` commands from the repository root** — there is no top-level Rails app
- **Do not create shared utilities between the three Structured-Event-Reporting projects** — they are intentionally independent
- **Do not fix RuboCop warnings in traditional projects without checking if they are intentional demo anti-patterns**
- **Do not add `Rails.event` to `rails-8-0-traditional/` or `rails-8-1-traditional/`**
- **Do not add RSpec to `Local CI/`** — it uses Minitest intentionally

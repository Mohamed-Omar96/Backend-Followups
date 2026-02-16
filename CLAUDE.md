# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of **three independent educational Rails demo projects**, each demonstrating a distinct Rails 8+ feature, plus associated Remotion video projects.

| Directory | Rails | Feature Demonstrated |
|---|---|---|
| `Job-Continuation/` | 8.1.1 / Ruby 3.3.6 | Resilient background jobs (`ActiveJob::Continuable` vs `job-iteration`) |
| `Local CI/` | 8.1.2 / Ruby 3.4.2 | Standardized CI via `bin/ci` + `config/ci.rb` |
| `Structured-Event-Reporting/` | 8.0–8.1 / Ruby 3.3+ | Logging evolution: `Rails.logger` → `Rails.event` |

Each project is **fully independent** with its own gems, database, and tests. Each has its own `CLAUDE.md` — **read the project-specific `CLAUDE.md` before working within any sub-project.**

## Project-Specific CLAUDE.md Files

- `Job-Continuation/CLAUDE.md` — job patterns, checkpoint mechanics, demo scripts
- `Local CI/CLAUDE.md` — `bin/ci` DSL, Minitest setup, scope constraints
- `Structured-Event-Reporting/CLAUDE.md` — 3-project rules, cross-project constraints, port assignments
- `Structured-Event-Reporting/rails-8-1-structured/CLAUDE.md` — `Rails.event` patterns, subscriber rules
- `Structured-Event-Reporting/video/CLAUDE.md` — Remotion/TypeScript rules
- `Local CI/video/CLAUDE.md` — Remotion video sub-project

## Key Cross-Project Rules

- **Anti-patterns in traditional projects are intentional.** In `Structured-Event-Reporting`, the two `rails-8-*-traditional` apps intentionally use inconsistent log formats, `Time.now`, and `Thread.current`. Do not fix them.
- **Never add `Rails.event` to traditional projects.**
- **Both job patterns (`rails_native/` and `job_iteration/`) must stay in sync** in Job-Continuation — same business logic, different APIs.
- **Educational clarity over cleverness.** All three repos are teaching material; keep code readable and comments in place.

## Quick Commands by Project

### Job-Continuation
```bash
cd Job-Continuation
script/setup                          # initial setup
bundle exec sidekiq -C config/sidekiq.yml  # start worker
bundle exec rspec spec/jobs           # run job tests
bundle exec rspec spec/integration    # run integration tests
rake demo:clean && rake 'demo:seed[quick]'  # reset demo data
```

### Local CI
```bash
cd "Local CI"
bin/setup --skip-server               # setup
./bin/ci                              # full CI suite (run before committing)
bin/rails test                        # all tests
bin/rails test test/models/article_test.rb:15  # single test by line number
```

### Structured-Event-Reporting
```bash
cd Structured-Event-Reporting
./scripts/setup_all.sh                # setup all 3 Rails apps
./scripts/start_all.sh                # start on ports 3000/3001/3002
./scripts/stop_all.sh
./scripts/verify_all.sh               # run all 3 test suites

# Individual projects
cd rails-8-0-traditional && bundle exec rspec
cd rails-8-1-traditional && bundle exec rspec
cd rails-8-1-structured  && bundle exec rspec
bundle exec rubocop                   # lint (run from within any project dir)

# Watch structured events live
tail -f rails-8-1-structured/log/events-development.json | jq -C '.'
```

### Video Projects (Remotion)
```bash
# Structured-Event-Reporting video
cd Structured-Event-Reporting/video
bun start          # Remotion Studio (localhost:3000)
bun run render     # render to out/video.mp4
bun run tts        # regenerate TTS narration (Python 3.11)
bun x tsc --noEmit # type-check

# Local CI video
cd "Local CI/video/local-ci-video"
npm start          # preview
npm run build      # render
```

## Technology Stack

- **Ruby**: 3.3.6 (Job-Continuation, Structured-Event-Reporting) / 3.4.2 (Local CI)
- **Database**: SQLite3 (all Rails projects)
- **Background jobs**: Sidekiq + Redis (Job-Continuation only)
- **Testing**: RSpec (Job-Continuation, Structured-Event-Reporting) / Minitest (Local CI)
- **Linting**: RuboCop with `rubocop-rails-omakase`
- **Video**: Remotion 4.0 (React/TypeScript), package manager is `bun` — never run `bundle install` inside video directories

## Git & Commit Rules

- **Never add `Co-Authored-By: Claude` or any Claude attribution to commit messages.**

## Comprehensive Developer Guides

Each project has a detailed `agents.md` (or `AGENTS.md`) file with architecture deep-dives, troubleshooting, and walkthrough scenarios — these are the primary reference for complex work:

- `Job-Continuation/agents.md`
- `Local CI/AGENTS.md`
- `Structured-Event-Reporting/AGENTS.md`

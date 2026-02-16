# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **For AI Coding Assistants:** See [AGENTS.md](AGENTS.md) for detailed guidelines on task patterns, code conventions, and educational focus.

## Project Overview

An **educational demonstration project** for the Rails 8.1 Local CI feature — showing how to standardize CI workflows between local development and cloud CI using `bin/ci` + `config/ci.rb`. The demo app (Article model/controller) exists solely to provide something meaningful for CI to test.

## Key Commands

```bash
./bin/ci                              # Run full CI suite — MANDATORY before committing
bin/rails test                        # Run all tests
bin/rails test test/models/article_test.rb  # Run a single test file
bin/rails test test/models/article_test.rb:15  # Run a single test by line number
bin/rails console                     # Open Rails console
bin/setup --skip-server               # Set up database and dependencies
```

## Local CI System

The core Rails 8.1 feature this project demonstrates:

**`config/ci.rb`** — DSL configuration for the CI workflow. Defines sequential `step(name, command)` calls inside a `CI.run` block. Supports conditionals via `success?`, `File.exist?`, and `Dir.exist?`. Uses `heading()` and `failure()` for custom output messages.

**`bin/ci`** — Thin runner that loads `ActiveSupport::ContinuousIntegration` and executes `config/ci.rb`. Sets `CI=true`, runs steps sequentially with timing, outputs color-coded results. This exact command runs in `.github/workflows/ci.yml` — no duplication between local and remote CI.

## Architecture

- **Ruby 3.4.2 / Rails 8.1.2** — `.ruby-version` and `.tool-versions` specify versions
- **SQLite3** — development and test database
- **Minitest** — test framework (no RSpec)
- **RuboCop** (`rubocop-rails-omakase`), **Bundler Audit**, **Brakeman** — quality/security tools invoked by `bin/ci`
- **Propshaft** — asset pipeline; **Hotwire** (Turbo + Stimulus) — frontend

## Multimedia Workspace (`video/`)

A separate multimedia sub-project lives in `video/` and is **not covered by `bin/ci`**. See `video/CLAUDE.md` for its own instructions.

| Folder | Stack | Key Command |
|--------|-------|-------------|
| `video/local-ci-video/` | Node 18 + Remotion (React) | `npm start` (preview), `npm run build` (render) |
| `video/local-ci-voice/` | Python 3.11 + venv | `source venv/bin/activate && python <script>.py` |

Never run Rails CI commands (`bin/ci`, `bin/rails`) for changes inside `video/`.

## Learning Exercises

`test/models/article_test.rb` contains 6 commented-out exercises demonstrating different CI failure types (wrong assertions, flaky tests, missing validations, syntax errors, slow tests, full failure→fix workflow). Uncomment one at a time, run `./bin/ci` to see the failure, then fix or re-comment.

## Documentation Map

| File | Purpose |
|------|---------|
| `LOCAL_CI_GUIDE.md` | Teaching guide: DSL reference, examples, exercises |
| `CODE_REVIEW.md` | Code review process integrating Local CI |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR checklist requiring `bin/ci` output |
| `docs/tasks.md` | Task tracking with checkboxes |
| `docs/references.md` | External resources and learning materials |

## Scope Constraint

This project's scope is intentionally limited to demonstrating Local CI. Do not add features, models, or complexity beyond what the educational purpose requires. Always run `./bin/ci` before marking any task complete.

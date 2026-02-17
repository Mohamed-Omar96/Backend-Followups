# Rails 8.1 Local CI Demo

> An educational demonstration project showcasing Rails 8.1's Local CI feature for standardizing continuous integration workflows.

## Overview

This project demonstrates how to use Rails 8.1's **Local CI** feature to run the same CI checks locally that run on your cloud CI server. This eliminates the "works on my machine" problem and helps catch issues before they reach code review.

### What is Local CI?

Rails 8.1 introduced a new CI framework that allows teams to define their entire CI workflow in a single Ruby configuration file (`config/ci.rb`). The same checks run identically both locally (via `bin/ci`) and on cloud CI platforms like GitHub Actions.

### Why This Matters

- ✅ **Catch issues early** - Run full CI suite before pushing code
- ✅ **Faster feedback** - No waiting for remote CI servers
- ✅ **Consistent results** - Same checks locally and remotely
- ✅ **Better reviews** - Reviewers can verify changes locally
- ✅ **Reduced costs** - Fewer failed builds on cloud infrastructure

## Getting Started

### Prerequisites

- Ruby 3.4+ (see `.tool-versions` or `.ruby-version`)
- Rails 8.1+
- SQLite3

### Setup

```bash
# Clone the repository (if not already local)
cd /path/to/Local\ CI

# Install dependencies
bundle install

# Setup database
bin/rails db:create
bin/rails db:migrate

# Run the test suite
bin/rails test
```

### Verify Installation

```bash
# Run the full CI suite
./bin/ci
```

You should see output like:
```
✅ Setup - passed (2.3s)
✅ Tests: Rails - passed (5.1s)
✅ Tests: System - passed (8.4s)

✅ All CI checks passed!
Your changes are ready for review
```

## Development Workflow

### Running Tests Locally

This project uses Rails 8.1 Local CI to standardize testing workflows:

```bash
# Run full CI suite (recommended before submitting PRs)
./bin/ci

# Run individual test suites
bin/rails test           # Unit/integration tests
bin/rails test:system    # System tests (if present)

# Run specific test files
bin/rails test test/models/article_test.rb
bin/rails test test/controllers/articles_controller_test.rb

# Run a specific test
bin/rails test test/models/article_test.rb:15
```

### Before Submitting a Pull Request

**Always follow this checklist:**

1. ✅ **Run Local CI** - Execute `./bin/ci` and ensure all checks pass
2. ✅ **Review your changes** - Use `git diff` to check what you're committing
3. ✅ **Update documentation** - Modify README, comments, or guides if needed
4. ✅ **Fill out PR template** - Complete all sections in `.github/PULL_REQUEST_TEMPLATE.md`
5. ✅ **Include CI output** - Paste your successful `bin/ci` run in the PR description

See [CODE_REVIEW.md](CODE_REVIEW.md) for complete guidelines.

### Local CI Configuration

The CI workflow is defined in `config/ci.rb`:

```ruby
CI.run do
  # Setup
  step "Setup", "bin/setup --skip-server"

  # Optional quality checks
  step "Style: Ruby", "bin/rubocop" if File.exist?("bin/rubocop")
  step "Security: Gem audit", "bin/bundler-audit" if File.exist?("bin/bundler-audit")

  # Tests
  step "Tests: Rails", "bin/rails test"
  step "Tests: System", "bin/rails test:system" if Dir.exist?("test/system")

  # Results
  if success?
    heading "✅ All CI checks passed!", "Your changes are ready for review"
  else
    failure "❌ CI checks failed", "Please fix the issues above before submitting your PR"
  end
end
```

See [LOCAL_CI_GUIDE.md](LOCAL_CI_GUIDE.md) for detailed documentation on the Local CI DSL.

## Project Structure

```
.
├── app/
│   ├── models/
│   │   └── article.rb           # Demo model with validations
│   └── controllers/
│       └── articles_controller.rb # Demo controller
├── test/
│   ├── models/
│   │   └── article_test.rb      # Model tests
│   └── controllers/
│       └── articles_controller_test.rb # Controller tests
├── config/
│   └── ci.rb                     # ⭐ Local CI configuration
├── bin/
│   └── ci                        # ⭐ CI runner script
├── docs/
│   ├── plan.md                   # Implementation plan
│   ├── tasks.md                  # Task tracking
│   └── references.md             # External resources
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md  # PR template with CI checklist
├── video/
│   ├── local-ci-video/           # Remotion (React) video project
│   └── local-ci-voice/           # Python TTS narration scripts
├── CODE_REVIEW.md                # Code review guidelines
├── LOCAL_CI_GUIDE.md             # ⭐ Complete Local CI guide
└── README.md                     # This file
```

> **Note:** `video/` is a separate multimedia workspace with its own toolchain (Node/Remotion + Python). It is not covered by `bin/ci`. See `video/CLAUDE.md` for details.

## Demo Application

This project includes a simple Article model to demonstrate CI in action:

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
end
```

The tests demonstrate how CI catches validation failures and other issues before they reach production.

## Documentation

### Learning Resources

- **[LOCAL_CI_GUIDE.md](LOCAL_CI_GUIDE.md)** - Complete guide to Rails 8.1 Local CI feature
  - What is Local CI and why it matters
  - How the DSL works
  - Practical examples and best practices
  - Troubleshooting tips

- **[CODE_REVIEW.md](CODE_REVIEW.md)** - Code review process with Local CI integration
  - Pre-review checklist
  - Step-by-step review process
  - Rails-specific checks
  - Approval criteria

### Development Guides

- **[CLAUDE.md](CLAUDE.md)** - Guidance for Claude Code when working in this repository
  - Project architecture and structure
  - Key commands and workflows
  - Development notes and best practices

- **[AGENTS.md](AGENTS.md)** - Guidelines for AI coding assistants
  - Task patterns and conventions
  - Code quality standards
  - Educational focus and scope management
  - Local CI integration workflow

### Project Planning

- **[docs/plan.md](docs/plan.md)** - Implementation plan and project structure

- **[docs/tasks.md](docs/tasks.md)** - Task tracking for implementation phases

## Common Commands

```bash
# Development
bin/rails server                  # Start Rails server
bin/rails console                 # Open Rails console

# Database
bin/rails db:create              # Create database
bin/rails db:migrate             # Run migrations
bin/rails db:rollback            # Rollback last migration
bin/rails db:reset               # Reset database (drop, create, migrate, seed)

# Testing
./bin/ci                         # Run full CI suite (RECOMMENDED)
bin/rails test                   # Run all tests
bin/rails test:system            # Run system tests
bin/rails test path/to/test.rb  # Run specific test file

# Code Quality (if installed)
bin/rubocop                      # Check Ruby style
bin/rubocop -a                   # Auto-fix style issues
bin/bundler-audit               # Check for vulnerable gems
```

## CI Integration

### GitHub Actions

This project demonstrates how to use the same `bin/ci` command in GitHub Actions. See [`.github/workflows/ci.yml`](.github/workflows/ci.yml) for the complete configuration.

**Simple approach**:
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.3
        bundler-cache: true
    - name: Run CI
      run: bin/ci
```

The beauty of Local CI: **One command, everywhere!** 🚀

No duplication, no drift, no "works on my machine" problems. For more details on GitHub Actions integration, see the [GitHub Actions Integration](LOCAL_CI_GUIDE.md#github-actions-integration) section in the Local CI Guide.

## Learning Resources

### Hands-On Exercises (Learn by Breaking Things!)

This project includes **6 interactive exercises** to help you understand how Local CI works. Each exercise demonstrates a different type of failure CI can catch.

**All exercises are in** `test/models/article_test.rb` **as commented code blocks.**

#### Quick Start

1. Open `test/models/article_test.rb`
2. Find the "LEARNING EXERCISES" section (around line 20)
3. Uncomment **one exercise at a time**
4. Run `./bin/ci` and observe the failure
5. Re-comment or fix the issue
6. Run `./bin/ci` again to verify it passes

#### What You'll Learn

- ✅ **Exercise 1**: How CI catches wrong assertions (logic errors)
- ✅ **Exercise 2**: How CI detects flaky tests (incorrect expectations)
- ✅ **Exercise 3**: How CI handles edge cases (validation gaps)
- ✅ **Exercise 4**: How CI catches syntax errors (Ruby parse errors)
- ✅ **Exercise 5**: How to identify slow tests (performance issues)
- ✅ **Exercise 6**: Complete workflow from failure to fix to commit

**Full details**: See [LOCAL_CI_GUIDE.md § Learning Exercises](LOCAL_CI_GUIDE.md#learning-exercises-hands-on-practice) for step-by-step instructions, expected outputs, and learning outcomes for each exercise.

### Why Practice Breaking Things?

Understanding **how CI fails** is just as important as knowing when it succeeds:

- 🔍 **Faster debugging** - Recognize error patterns quickly
- 🛡️ **Better testing** - Write tests that actually catch bugs
- 🚀 **More confidence** - Know your CI setup works before pushing
- 📚 **Team knowledge** - Share common failure patterns with teammates

### External Resources

- [Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)
- [Saeloun: Rails Local CI Tutorial](https://blog.saeloun.com/2025/12/17/rails-introduces-ci-to-streamline-new-dsl/)
- [FastRuby: Rails 8.1 Local CI](https://www.fastruby.io/blog/rails-8-1-local-ci.html)

## Contributing

This is an educational demo project. When making changes:

1. Run `./bin/ci` before committing
2. Follow the [CODE_REVIEW.md](CODE_REVIEW.md) guidelines
3. Fill out the PR template completely
4. Include your CI output in the PR description

**For AI-assisted development:** See [AGENTS.md](AGENTS.md) for detailed guidelines on maintaining educational quality, code conventions, and Local CI integration when using AI coding assistants.

## Ruby Version

This project uses Ruby 3.4.2 (specified in `.tool-versions`).

```bash
# Check your Ruby version
ruby -v

# If using asdf
asdf install ruby 3.4.2
```

## Rails Version

Rails 8.1.2 - The first version with Local CI support.

## Database

SQLite3 (development and test) - Simple and sufficient for this demo.

## License

This is an educational demonstration project for internal team use.

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./bin/ci` | **Run full CI suite (use this!)** |
| `bin/rails test` | Run unit/integration tests |
| `bin/rails test:system` | Run system tests |
| `bin/rails console` | Open Rails console |
| `bin/rails server` | Start development server |

**Remember**: Always run `./bin/ci` before submitting a pull request! ✅

---

## Questions?

- Check [LOCAL_CI_GUIDE.md](LOCAL_CI_GUIDE.md) for detailed documentation
- See [CODE_REVIEW.md](CODE_REVIEW.md) for review process
- Ask the backend team for help

**Happy coding! 🎉**

# Run using bin/ci
#
# This file defines the Local CI workflow for this Rails application.
# Rails 8.1 introduced Local CI to standardize testing between local development
# and cloud CI servers, eliminating "works locally, fails in CI" problems.
#
# The CI.run block defines sequential steps that execute when you run `bin/ci`.
# Each step runs a command and reports success/failure with timing information.

CI.run do
  # Step 1: Setup the test environment
  # This ensures the database is set up and dependencies are installed
  step "Setup", "bin/setup --skip-server"

  # Step 2: Code Style Check (RuboCop)
  # Only runs if bin/rubocop exists - demonstrates conditional execution
  if File.exist?("bin/rubocop")
    step "Style: Ruby", "bin/rubocop"
  end

  # Step 3: Security Audit (Bundler Audit)
  # Only runs if bin/bundler-audit exists - checks for vulnerable gems
  if File.exist?("bin/bundler-audit")
    step "Security: Gem audit", "bin/bundler-audit"
  end

  # Step 4: Run all Rails tests (models, controllers, helpers, etc.)
  # This is the core testing step - ensures all unit/integration tests pass
  step "Tests: Rails", "bin/rails test"

  # Step 5: Run system tests (browser-based tests with Capybara)
  # Only runs if test/system directory exists
  if Dir.exist?("test/system")
    step "Tests: System", "bin/rails test:system"
  end

  # Success/Failure messaging
  # The success? method checks if all previous steps passed
  if success?
    heading "✅ All CI checks passed!", "Your changes are ready for review"
  else
    failure "❌ CI checks failed", "Please fix the issues above before submitting your PR"
  end
end

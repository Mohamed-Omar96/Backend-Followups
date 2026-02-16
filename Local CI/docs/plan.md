# Plan: Rails 8.1 Local CI Demo & Documentation Project

## Context

This project aims to create an educational demonstration of Rails 8.1's Local CI feature for teaching the backend team. The Local CI feature (`bin/ci` + `config/ci.rb`) was introduced in Rails 8.1 to standardize CI workflows between local development and cloud CI servers, eliminating "works locally, fails in CI" problems.

The goal is to:
1. Create a working Rails 8.1 application demonstrating Local CI
2. Provide comprehensive documentation for code review integration
3. Show best practices for running CI locally before submitting PRs
4. Create templates and guidelines the team can reuse

## Implementation Plan

### 1. Create Rails 8.1 Application

**Location**: Current directory (`/Users/mohamedomarwork/Documents/Work/Backend-followup/Local CI`)

**Actions**:
- Generate a new Rails 8.1 application with default settings
- Use SQLite for simplicity (minimal demo scope)
- Ensure Rails 8.1 is available (check Ruby/Rails version requirements)

**Command**:
```bash
rails new . --skip-git
```

### 2. Create Demo Application Code

**Purpose**: Demonstrate that CI can catch real issues

**Components to create**:
- **Model**: `Article` with title and body fields
  - Add validations (presence of title)
  - Location: `app/models/article.rb`

- **Controller**: `ArticlesController` with basic CRUD
  - Location: `app/controllers/articles_controller.rb`

- **Tests**:
  - Model tests for validations
  - Controller tests for basic actions
  - Location: `test/models/article_test.rb`, `test/controllers/articles_controller_test.rb`

### 3. Configure Local CI (`config/ci.rb`)

**File**: `config/ci.rb`

**Configuration to include**:
```ruby
CI.run do
  step "Setup", "bin/setup --skip-server"
  step "Style: Ruby", "bin/rubocop" if File.exist?("bin/rubocop")
  step "Security: Gem audit", "bin/bundler-audit" if File.exist?("bin/bundler-audit")
  step "Tests: Rails", "bin/rails test"
  step "Tests: System", "bin/rails test:system" if Dir.exist?("test/system")

  if success?
    heading "✅ All CI checks passed!", "Your changes are ready for review"
  else
    failure "❌ CI checks failed", "Please fix the issues above before submitting your PR"
  end
end
```

**Notes**:
- Keep it simple for the minimal demo
- Focus on demonstrating the DSL syntax
- Include conditional steps to show the `if success?` pattern
- Add friendly messaging for success/failure states

### 4. Create Comprehensive Documentation

#### 4.1. LOCAL_CI_GUIDE.md (Teaching Guide)

**Purpose**: Educational resource for the backend team

**Sections to include**:
1. **What is Rails 8.1 Local CI?**
   - Overview of the feature
   - Why it was introduced
   - Benefits for teams

2. **How It Works**
   - Explain `config/ci.rb` DSL
   - Explain `bin/ci` runner
   - Show the workflow

3. **DSL Reference**
   - `CI.run` block
   - `step(name, command)` method
   - `success?` conditional
   - `failure(heading, message)` method
   - `heading()` for custom output

4. **Practical Examples**
   - Basic configuration
   - Advanced patterns (conditional steps, custom checks)
   - Integration with existing tools

5. **Best Practices**
   - When to run `bin/ci`
   - How to debug failures
   - Tips for fast CI runs

6. **Resources & References**
   - Links to official Rails guides
   - Links to blog posts and articles

#### 4.2. CODE_REVIEW.md (Reviewer Guidelines)

**Purpose**: Checklist and guidelines for code reviewers

**Sections to include**:
1. **Pre-Review Checklist**
   - ✅ Author has confirmed local CI passed
   - ✅ PR description includes testing evidence
   - ✅ All GitHub Actions checks are green

2. **Code Review Process**
   - Pull the branch locally
   - Run `bin/ci` yourself
   - Review code changes
   - Check test coverage
   - Verify documentation updates

3. **Local CI Integration**
   - **When to run CI**: Before approving any PR
   - **How to run**: `./bin/ci` from project root
   - **What to check**: All steps should pass with green output
   - **If it fails**: Request changes with specific feedback

4. **Rails-Specific Checks**
   - Database migrations are reversible
   - N+1 queries avoided
   - Security concerns addressed
   - Performance considerations

5. **Approval Criteria**
   - All tests pass (local and CI)
   - Code follows team conventions
   - Documentation is updated
   - No security vulnerabilities

#### 4.3. PULL_REQUEST_TEMPLATE.md (GitHub Template)

**Location**: `.github/PULL_REQUEST_TEMPLATE.md`

**Content**:
```markdown
## Description
<!-- Describe what this PR does and why -->

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Local Testing Checklist
**Before submitting this PR, I have:**
- [ ] Run `bin/ci` locally and all checks passed ✅
- [ ] Tested the changes manually in development
- [ ] Added/updated tests for new functionality
- [ ] Updated documentation as needed
- [ ] Verified no console errors or warnings

## CI Output
<!-- Paste a screenshot or summary of your successful local CI run -->
Example:
```
✅ Setup - passed (2.3s)
✅ Tests: Rails - passed (5.1s)
All CI checks passed!
```

## Testing Instructions
<!-- How should reviewers test this? -->

## Related Issues
<!-- Link to related issues/tickets -->
```

#### 4.4. README.md Updates

**Section to add**: "Development Workflow"

**Content**:
```markdown
## Development Workflow

### Running Tests Locally

This project uses Rails 8.1 Local CI to standardize testing workflows:

```bash
# Run full CI suite (recommended before submitting PRs)
./bin/ci

# Run individual test suites
bin/rails test           # Unit/integration tests
bin/rails test:system    # System tests

# Run specific test files
bin/rails test test/models/article_test.rb
```

### Before Submitting a Pull Request

1. ✅ Run `bin/ci` and ensure all checks pass
2. ✅ Review your changes
3. ✅ Update documentation if needed
4. ✅ Fill out the PR template completely
5. ✅ Include CI output in your PR description

See [CODE_REVIEW.md](CODE_REVIEW.md) for complete guidelines.
```

### 5. Create Example GitHub Actions Integration (Optional)

**File**: `.github/workflows/ci.yml`

**Purpose**: Show how the same `bin/ci` runs in GitHub Actions

**Content**:
```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.3
        bundler-cache: true

    - name: Run CI
      run: bin/ci
```

**Note**: This demonstrates the power of Local CI - the same command runs everywhere!

### 6. Create Project Documentation Structure

**Directory**: `docs/`

Create a dedicated documentation folder to organize project planning and task tracking:

#### 6.1. docs/plan.md

**Purpose**: Persistent copy of the implementation plan for reference

**Content**: Copy of this complete plan including:
- Context and goals
- Implementation steps
- Critical files
- Verification steps
- References

#### 6.2. docs/tasks.md

**Purpose**: Detailed task breakdown for implementation tracking

### 7. Add Example Scenarios

**Create intentional issues to demonstrate CI catching problems**:

1. **Failing test scenario**: Comment out a validation in a test to show how CI catches it
2. **Lint issue scenario**: Add a style violation that RuboCop would catch (if included)

Include these as commented examples in the codebase with instructions in LOCAL_CI_GUIDE.md on how to trigger them for learning purposes.

## Critical Files

1. `config/ci.rb` - Local CI configuration (core of the demo)
2. `bin/ci` - Generated by Rails, ensures it's executable
3. `.github/PULL_REQUEST_TEMPLATE.md` - PR template with CI checklist
4. `CODE_REVIEW.md` - Code review guidelines
5. `LOCAL_CI_GUIDE.md` - Educational guide for the team
6. `README.md` - Quick reference and setup instructions
7. `app/models/article.rb` - Demo model
8. `test/models/article_test.rb` - Demo tests
9. `docs/plan.md` - This implementation plan
10. `docs/tasks.md` - Task tracking

## Verification Steps

After implementation, verify the project works:

1. **Test the Rails app**:
   ```bash
   cd /Users/mohamedomarwork/Documents/Work/Backend-followup/Local\ CI
   bin/rails db:create db:migrate
   ```

2. **Run Local CI**:
   ```bash
   ./bin/ci
   ```
   - Should see all steps execute sequentially
   - Should display colored output with timing
   - Should show success message if all pass

3. **Test CI failure scenario**:
   - Modify a test to fail intentionally
   - Run `./bin/ci` again
   - Verify it shows failure message and exits with error code

4. **Review documentation**:
   - Read through each documentation file
   - Ensure all links work
   - Verify instructions are clear and complete

5. **Test GitHub integration** (if applicable):
   - Create a test PR
   - Verify PR template appears
   - Verify checklist makes sense in context

## Success Criteria

✅ Rails 8.1 application created and working
✅ `config/ci.rb` configured with clear examples
✅ `bin/ci` runs successfully with all tests passing
✅ All four documentation files created and comprehensive
✅ PR template includes local CI verification checklist
✅ README has clear quick-start instructions
✅ Demo code (Article model/tests) demonstrates real CI usage
✅ Team can use this as both a learning resource and template
✅ docs/ folder with plan.md and tasks.md for organization

## References

- [Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)
- [Rails 8.1 Official Announcement](https://rubyonrails.org/2025/10/22/rails-8-1)
- [Saeloun Blog: Rails 8.1 Local CI](https://blog.saeloun.com/2025/12/17/rails-introduces-ci-to-streamline-new-dsl/)
- [Rails GitHub Commit: Structured CI](https://github.com/rails/rails/commit/bcd5c93609c5854399dfb960b3666d318f469eb8)
- [FastRuby.io: Rails 8.1 Local CI](https://www.fastruby.io/blog/rails-8-1-local-ci.html)
- [GitHub PR Template Best Practices](https://www.pullchecklist.com/posts/github-pull-request-template-checklist)
- [Code Review Checklist Resources](https://github.com/mgreiler/code-review-checklist)

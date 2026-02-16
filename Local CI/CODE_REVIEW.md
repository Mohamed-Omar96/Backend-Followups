# Code Review Guidelines

## Overview

This document provides guidelines for conducting thorough and effective code reviews, with a special focus on integrating Rails 8.1 Local CI into the review process.

## Table of Contents
1. [Pre-Review Checklist](#pre-review-checklist)
2. [Code Review Process](#code-review-process)
3. [Local CI Integration](#local-ci-integration)
4. [Rails-Specific Checks](#rails-specific-checks)
5. [Approval Criteria](#approval-criteria)
6. [Common Issues & Solutions](#common-issues--solutions)

---

## Pre-Review Checklist

Before diving into the code, verify these items are in place:

### Author's Responsibilities

- [ ] **Local CI passed** - Author confirms they ran `bin/ci` successfully
- [ ] **PR description complete** - Clear description of changes and why
- [ ] **CI output included** - Screenshot or summary of successful `bin/ci` run
- [ ] **Tests added/updated** - New functionality has corresponding tests
- [ ] **Documentation updated** - README, comments, or guides reflect changes
- [ ] **Self-review completed** - Author reviewed their own diff first

### GitHub Checks

- [ ] **All CI checks green** - GitHub Actions or other cloud CI passed
- [ ] **No merge conflicts** - Branch is up-to-date with target branch
- [ ] **Reasonable size** - PR is focused and reviewable (ideally < 400 lines)

### Red Flags to Watch For

⚠️ If any of these are missing, **request them before starting review**:
- No mention of local CI being run
- PR description says "WIP" or "TODO"
- Multiple unrelated changes in one PR
- Large refactoring mixed with feature changes

---

## Code Review Process

Follow this systematic approach for thorough reviews:

### 1. Understand the Context

**Before looking at code**:
- Read the PR description thoroughly
- Check linked issues or tickets
- Understand the "why" behind the changes
- Review any design documents or discussions

**Ask yourself**:
- What problem is this solving?
- Is this the right approach?
- Are there simpler alternatives?

### 2. Pull the Branch Locally

**Always review code on your local machine**:

```bash
# Fetch the branch
git fetch origin
git checkout feature-branch-name

# Or use GitHub CLI
gh pr checkout 123

# Install dependencies if needed
bundle install
```

**Why local review matters**:
- ✅ Run the code yourself
- ✅ Test edge cases manually
- ✅ Verify CI passes in your environment
- ✅ Check actual behavior, not just code

### 3. Run Local CI

**This is the most important step**:

```bash
# Run full CI suite
./bin/ci
```

**Expected output**:
```
✅ Setup - passed (2.3s)
✅ Tests: Rails - passed (5.1s)
✅ Tests: System - passed (8.4s)

✅ All CI checks passed!
Your changes are ready for review
```

**If CI fails**:
```
❌ Tests: Rails - failed (3.2s)

❌ CI checks failed
Please fix the issues above before submitting your PR
```

**Action**: Request changes immediately if CI fails locally.

### 4. Review the Code

**Read through changes systematically**:

#### Code Quality
- [ ] Code is readable and well-structured
- [ ] Variable/method names are clear and descriptive
- [ ] Logic is easy to follow
- [ ] No unnecessary complexity
- [ ] Comments explain "why" not "what" (when needed)

#### Functionality
- [ ] Code does what the PR description claims
- [ ] Edge cases are handled
- [ ] Error handling is appropriate
- [ ] No hardcoded values (use constants/config)

#### Tests
- [ ] Tests cover new functionality
- [ ] Tests are clear and meaningful
- [ ] Test names describe what they test
- [ ] Edge cases are tested
- [ ] No brittle tests (over-reliance on specific order, timestamps, etc.)

#### Security
- [ ] No sensitive data exposed
- [ ] Input is validated and sanitized
- [ ] SQL injection prevented (use parameterized queries)
- [ ] XSS vulnerabilities addressed
- [ ] Authentication/authorization checks in place

### 5. Test Manually

**Don't just trust the tests**:

```bash
# Start Rails server
bin/rails server

# Or Rails console for quick checks
bin/rails console

# Test the feature manually
# Click through UI changes
# Try edge cases and error scenarios
```

### 6. Check Database Changes

**If migrations are included**:

```bash
# Run migrations
bin/rails db:migrate

# Test rollback
bin/rails db:rollback

# Check schema changes
git diff db/schema.rb
```

---

## Local CI Integration

### Why Local CI Matters for Code Review

Local CI ensures:
1. **Consistency** - Same checks author ran
2. **Confidence** - Verify changes don't break existing code
3. **Speed** - Catch issues before requesting changes
4. **Thoroughness** - Automated checks complement manual review

### Running Local CI During Review

**Step-by-step workflow**:

1. **Check out the PR branch**:
   ```bash
   gh pr checkout 123
   # or
   git checkout feature-branch
   ```

2. **Update dependencies**:
   ```bash
   bundle install
   ```

3. **Run Local CI**:
   ```bash
   ./bin/ci
   ```

4. **Interpret results**:
   - ✅ **All green** → Proceed with code review
   - ⚠️ **Warnings** → Note in review comments
   - ❌ **Failures** → Request changes immediately

### What to Do When CI Fails

**If `bin/ci` fails during your review**:

1. **Document the failure**:
   - Copy the error output
   - Note which step failed
   - Identify the root cause if obvious

2. **Request changes**:
   ```markdown
   ## CI Failure

   When I ran `bin/ci` locally, the test suite failed:

   ```
   ❌ Tests: Rails - failed (3.2s)

   ArticleTest#test_should_not_save_article_without_title [test/models/article_test.rb:15]:
   Expected true to be false.
   ```

   Please fix this test failure and re-run `bin/ci` before I continue the review.
   ```

3. **Don't approve until fixed** - CI must pass before approval

### Verifying CI Claims

**If author claims CI passed but you want proof**:

- Check PR description for CI output
- Look for screenshots or terminal output
- Run `bin/ci` yourself to verify
- Check GitHub Actions logs

**Trust but verify** - It's okay to double-check!

---

## Rails-Specific Checks

### Database Migrations

- [ ] **Reversible** - Migrations can be rolled back safely
- [ ] **No data loss** - Removing columns doesn't delete critical data
- [ ] **Indexed** - Foreign keys and frequently queried columns have indexes
- [ ] **Safe for production** - No long-running ALTER TABLE on large tables

**Example - Bad migration**:
```ruby
# This will lock the entire table!
def change
  add_column :articles, :view_count, :integer, default: 0
end
```

**Better approach**:
```ruby
# For large tables, add column without default first
def change
  add_column :articles, :view_count, :integer
  # Backfill in batches separately
end
```

### N+1 Query Prevention

**Watch for**:
```ruby
# Bad - N+1 query
@articles = Article.all
@articles.each do |article|
  puts article.author.name  # Separate query for each article!
end

# Good - Eager loading
@articles = Article.includes(:author).all
@articles.each do |article|
  puts article.author.name  # No additional queries
end
```

**How to verify**:
- Check for `includes`, `joins`, or `preload` in controllers
- Look at test logs for multiple SELECT queries
- Use Bullet gem in development to detect N+1

### Security Concerns

- [ ] **Mass assignment** - Use strong parameters
- [ ] **SQL injection** - No string interpolation in queries
- [ ] **Authentication** - Protected controller actions use `before_action :authenticate_user!`
- [ ] **Authorization** - Users can only access their own resources
- [ ] **XSS** - User input is escaped in views (Rails does this by default with `<%= %>`)

**Example - Check strong parameters**:
```ruby
# Good
def article_params
  params.require(:article).permit(:title, :body)
end

# Bad - Permits everything!
params.require(:article).permit!
```

### Performance Considerations

- [ ] **Query optimization** - Avoid loading unnecessary data
- [ ] **Caching** - Consider fragment/action caching for expensive operations
- [ ] **Background jobs** - Long-running tasks use ActiveJob
- [ ] **Asset size** - No large images or files committed

### Rails Best Practices

- [ ] **RESTful routes** - Follow REST conventions
- [ ] **Skinny controllers** - Business logic in models or services
- [ ] **DRY code** - No repetition, use partials/helpers
- [ ] **Rails conventions** - Follow naming and structure conventions

---

## Approval Criteria

### Required Before Approval

All of these must be true:

✅ **Local CI passes** - You ran `./bin/ci` successfully
✅ **Tests pass** - All tests green, including new tests
✅ **No regressions** - Existing functionality still works
✅ **Code quality** - Readable, maintainable, follows conventions
✅ **Security reviewed** - No obvious vulnerabilities
✅ **Documentation updated** - Changes are documented
✅ **PR description complete** - Clear explanation of changes

### When to Request Changes

Request changes if:
- CI fails locally
- Tests are insufficient or failing
- Security vulnerabilities present
- Code is hard to understand
- Breaking changes without migration path
- Requires significant refactoring

### When to Approve

Approve when:
- All criteria above are met
- You understand the changes
- You're confident it won't break production
- You'd be comfortable deploying it

### Approval Comments

**Good approval comment**:
```markdown
✅ **Approved!**

- Ran `bin/ci` locally - all checks passed
- Tested the feature manually - works as described
- Code is clean and well-tested
- No security concerns

Nice work on handling the edge case with empty titles!
```

**Not helpful**:
```markdown
LGTM
```

### Providing Feedback

**Be constructive and specific**:

**Good feedback**:
```markdown
Consider using `Article.includes(:author)` here to avoid N+1 queries when displaying author names in the list view.
```

**Not helpful**:
```markdown
This code is bad.
```

**Use suggestions**:
```markdown
Suggestion:
```ruby
# Use a constant instead of magic number
MAX_ARTICLES = 10

def recent_articles
  Article.limit(MAX_ARTICLES)
end
```
```

---

## Common Issues & Solutions

### Issue: CI passes for author but fails for you

**Possible causes**:
- Outdated dependencies on your machine
- Different Ruby/Rails versions
- Environment variables not set

**Solution**:
```bash
# Update dependencies
bundle install

# Check Ruby version matches
cat .ruby-version
ruby -v

# Reset database
bin/rails db:drop db:create db:migrate
```

### Issue: Tests pass but feature doesn't work

**Possible causes**:
- Tests aren't testing the right thing
- Tests have false positives
- Missing integration tests

**Solution**:
- Test the feature manually
- Request additional tests
- Suggest integration/system tests

### Issue: PR is too large to review

**Solution**:
- Request the PR be split into smaller chunks
- Review high-risk areas first
- Focus on critical business logic

### Issue: Unclear what the code does

**Solution**:
- Ask questions in the PR comments
- Request clarifying comments in code
- Suggest more descriptive naming

---

## Review Time Expectations

### Response Time
- **Initial review**: Within 24 hours of submission
- **Follow-up review**: Within 4 hours of changes

### Review Duration
- **Small PR (< 100 lines)**: 15-30 minutes
- **Medium PR (100-400 lines)**: 30-60 minutes
- **Large PR (> 400 lines)**: Request splitting or budget 1-2 hours

### Priority Levels
1. **🔥 Urgent** - Hotfixes, security patches (review immediately)
2. **⚡ High** - Blocking work, time-sensitive features (same day)
3. **📋 Normal** - Regular features, improvements (within 24 hours)
4. **🔍 Low** - Documentation, minor tweaks (within 48 hours)

---

## Checklist Summary

Use this quick checklist for every review:

```markdown
## Code Review Checklist

### Pre-Review
- [ ] Author confirmed local CI passed
- [ ] PR description is clear and complete
- [ ] All GitHub checks are green

### Local Verification
- [ ] Pulled branch locally
- [ ] Ran `./bin/ci` successfully
- [ ] Tested feature manually

### Code Review
- [ ] Code is readable and maintainable
- [ ] Tests cover new functionality
- [ ] No security vulnerabilities
- [ ] No performance concerns
- [ ] Follows Rails conventions

### Database Changes (if applicable)
- [ ] Migrations are reversible
- [ ] Indexes added where needed
- [ ] No data loss risk

### Approval
- [ ] All criteria met
- [ ] Confident to deploy
- [ ] Left constructive feedback
```

---

## Resources

- [LOCAL_CI_GUIDE.md](LOCAL_CI_GUIDE.md) - Complete guide to Rails Local CI
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html) - Official testing documentation
- [Code Review Checklist](https://github.com/mgreiler/code-review-checklist) - Comprehensive review checklist
- [Thoughtbot Code Review Guide](https://github.com/thoughtbot/guides/tree/main/code-review) - Industry best practices

---

**Remember**: Code review is about collaboration, not criticism. The goal is to help each other write better code and learn from each other.

Happy reviewing! 🎯

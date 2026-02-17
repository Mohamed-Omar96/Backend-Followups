# AGENTS.md

This file provides specific guidance for AI coding assistants (Claude Code, Cursor, GitHub Copilot, etc.) working in this repository.

## Project Context

This is an **educational demonstration project** for Rails 8.1 Local CI. Every decision should prioritize:
1. **Educational value** - Code should be clear and teach concepts
2. **Simplicity** - Avoid over-engineering; keep it minimal
3. **Demonstration** - Focus on showing Local CI in action

**This is NOT a production application.** Optimize for learning, not scalability.

## Core Principles for AI Agents

### 1. Always Run Local CI Before Completing Tasks

When making code changes:
```bash
# MANDATORY before marking any task complete
./bin/ci
```

If `bin/ci` fails, your task is NOT complete. Fix issues until it passes.

### 2. Maintain Educational Quality

**DO:**
- Add clear, teaching-focused comments to `config/ci.rb`
- Keep code examples simple and readable
- Explain "why" in documentation, not just "how"
- Use descriptive variable and method names
- Include examples that demonstrate concepts

**DON'T:**
- Add complex abstractions or premature optimizations
- Use advanced Ruby features that obscure the learning goal
- Add dependencies unless absolutely necessary
- Over-engineer solutions

### 3. Preserve Project Scope

This project demonstrates Local CI, not a full-featured Rails app. When asked to add features:

**In scope:**
- Local CI configuration improvements
- Documentation enhancements
- Learning exercises that demonstrate CI
- Simple examples showing CI catching issues

**Out of scope:**
- Authentication systems
- Complex business logic
- API integrations
- Advanced Rails features unrelated to CI
- Production-ready features

Always ask: "Does this help teach Local CI?" If no, don't add it.

## Common Tasks & Patterns

### Adding a New CI Step

When adding steps to `config/ci.rb`:

```ruby
# ✅ GOOD: Clear name, conditional execution, commented
# Check code style with RuboCop
step "Style: Ruby", "bin/rubocop" if File.exist?("bin/rubocop")

# ❌ BAD: No context, unclear purpose
step "Run check", "bin/some_tool"
```

**Always:**
1. Add a descriptive comment explaining what the step does
2. Use conditional execution for optional tools
3. Test by running `./bin/ci` locally
4. Update `LOCAL_CI_GUIDE.md` if adding new patterns

### Modifying Tests

All test changes must:
1. Keep tests simple and focused
2. Use descriptive test names that explain what's being tested
3. Follow Minitest conventions (not RSpec)
4. Pass `./bin/ci` before completion

**Example:**
```ruby
# ✅ GOOD: Clear name, tests one thing, demonstrates CI value
test "should not save article without title" do
  article = Article.new(body: "Some content")
  assert_not article.save, "Saved article without required title"
end

# ❌ BAD: Unclear what's being tested
test "validation" do
  article = Article.new
  assert_not article.valid?
end
```

### Updating Documentation

When updating any documentation file:

**For CODE_REVIEW.md:**
- Keep checklists actionable and specific
- Reference Local CI integration
- Include examples of good/bad patterns

**For LOCAL_CI_GUIDE.md:**
- Use teaching tone (explain concepts to backend developers)
- Include practical examples with expected output
- Add "Why this matters" context

**For README.md:**
- Keep it concise (overview/quick start)
- Link to detailed docs rather than duplicating content
- Update command reference if adding new commands

**For CLAUDE.md/AGENTS.md:**
- Focus on architectural decisions
- Explain patterns that aren't obvious from code
- Update when project structure changes

### Creating Learning Exercises

When adding exercises to `test/models/article_test.rb`:

```ruby
# ✅ GOOD: Commented out, clear instructions, demonstrates specific failure
# LEARNING EXERCISE 3: Edge Case Validation
# Uncomment the test below, run `./bin/ci`, and observe how CI catches
# the missing validation for empty strings.
#
# test "should not save article with empty title" do
#   article = Article.new(title: "   ", body: "Content")
#   assert_not article.save
# end

# ❌ BAD: Not commented, no context
test "some edge case" do
  article = Article.new(title: "", body: "")
  assert_not article.valid?
end
```

## Code Patterns & Conventions

### Rails Conventions

Follow Rails 8.1 conventions strictly:
- Use `bin/rails` for all Rails commands
- Follow RESTful routing patterns
- Use Strong Parameters in controllers
- Migrations should be reversible
- Use `ApplicationRecord` as base model class

### Testing Conventions

- **Framework:** Minitest (Rails default)
- **File naming:** `test/models/article_test.rb` (match model name)
- **Test naming:** `test "should do something"`
- **Assertions:** Use descriptive failure messages
- **Fixtures:** Keep minimal (this is a demo)

### Code Style

This project uses RuboCop with Rails Omakase style:
```bash
# Check style
bin/rubocop

# Auto-fix safe issues
bin/rubocop -a
```

**Key style points:**
- 2-space indentation
- Double quotes for strings (Rails convention)
- No trailing whitespace
- Empty line at end of files
- Max 120 character line length

## What NOT to Do

### ❌ Don't Add Features Beyond Scope

```ruby
# ❌ BAD: Adding authentication (out of scope)
class User < ApplicationRecord
  has_secure_password
  has_many :articles
end

# ✅ GOOD: Keep Article simple for demo
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true
end
```

### ❌ Don't Skip Running bin/ci

```bash
# ❌ BAD: Committing without verification
git commit -m "Add feature"

# ✅ GOOD: Always verify first
./bin/ci
git commit -m "Add feature"
```

### ❌ Don't Remove Learning Exercises

The commented exercises in `test/models/article_test.rb` are intentional:
- They demonstrate different failure types
- They're part of the educational value
- Keep them commented out in the main branch

### ❌ Don't Duplicate Documentation

```markdown
❌ BAD: Copying full command list to multiple files
- README.md has full command reference
- CLAUDE.md has full command reference
- LOCAL_CI_GUIDE.md has full command reference

✅ GOOD: Single source of truth with references
- README.md has quick reference table
- CLAUDE.md references README for commands
- LOCAL_CI_GUIDE.md links to README for setup
```

## Local CI Integration

### Before Starting Work

```bash
# 1. Ensure clean slate
./bin/ci

# 2. Create branch (if using git)
git checkout -b feature-name

# 3. Make changes
```

### During Development

```bash
# Run frequently to catch issues early
./bin/ci

# Run specific test for faster iteration
bin/rails test test/models/article_test.rb

# Check style independently if needed
bin/rubocop
```

### Before Committing

```bash
# MANDATORY: Full CI suite must pass
./bin/ci

# If it passes, proceed with commit
git add .
git commit -m "Descriptive message"
```

## Task Completion Checklist

When an AI agent completes a task, verify:

- [ ] Code changes are minimal and focused
- [ ] `./bin/ci` passes completely (all green)
- [ ] New code includes appropriate tests
- [ ] Documentation updated if behavior changed
- [ ] No unnecessary dependencies added
- [ ] Code follows Rails and project conventions
- [ ] Educational value maintained or improved
- [ ] No features added outside project scope

## Error Handling

### When bin/ci Fails

```bash
# 1. Identify which step failed
./bin/ci
# Output shows: "❌ Tests: Rails - failed"

# 2. Run that step directly for details
bin/rails test

# 3. Fix the issue

# 4. Verify fix
./bin/ci
```

### Common Issues

**Test failures:**
- Check validations match test expectations
- Ensure fixtures are correct
- Verify database schema is current (`bin/rails db:migrate`)

**RuboCop failures:**
- Auto-fix: `bin/rubocop -a`
- Manual fix: Read RuboCop output for specific violations

**Bundler Audit issues:**
- Update vulnerable gems: `bundle update [gem-name]`
- Check `config/bundler-audit.yml` for ignored issues

## Communication with Users

When responding to user requests:

**DO:**
- Explain what you're doing and why
- Reference Local CI when making changes
- Suggest running `./bin/ci` after changes
- Mention if a change affects documentation

**DON'T:**
- Make changes without explaining the educational impact
- Add features without confirming they're in scope
- Skip testing steps
- Assume production-level requirements apply

## Examples of Good Agent Behavior

### Example 1: Adding a New Validation

**User:** "Add validation to ensure article body is at least 10 characters"

**Good Response:**
```
I'll add a length validation to the Article model and include a test to verify it.

1. Update app/models/article.rb with the validation
2. Add test in test/models/article_test.rb
3. Run ./bin/ci to verify everything passes

This demonstrates how Local CI catches validation issues before code review.
```

**Then:**
1. Make the changes
2. Run `./bin/ci`
3. Show the output
4. Confirm completion only if CI passes

### Example 2: User Asks for Production Feature

**User:** "Add user authentication and associate articles with users"

**Good Response:**
```
This feature is outside the scope of this educational demo project.
The project focuses specifically on demonstrating Rails 8.1 Local CI,
not building a production-ready application.

Would you like me to:
1. Add a simpler feature that demonstrates Local CI catching issues?
2. Add documentation about how Local CI would work with authentication?
3. Create a learning exercise showing validation testing patterns?

The goal is to keep the codebase simple so the Local CI concepts are clear.
```

## File Organization

### Priority Files (Change Often)
- `config/ci.rb` - Local CI configuration
- `test/models/article_test.rb` - Demo tests with exercises
- `LOCAL_CI_GUIDE.md` - Teaching documentation
- `CODE_REVIEW.md` - Review process

### Structure Files (Change Rarely)
- `CLAUDE.md` - Claude Code guidance
- `AGENTS.md` - This file
- `README.md` - Project overview
- `docs/plan.md` - Implementation blueprint

### Generated/Standard Files (Don't Modify Unless Necessary)
- `config/routes.rb` - Keep minimal
- `app/controllers/application_controller.rb` - Rails defaults
- `test/test_helper.rb` - Rails defaults
- `Gemfile` - Only add gems that demonstrate CI concepts

### Multimedia Workspace (Separate Toolchain)
- `video/local-ci-video/` - Remotion (React/TypeScript) video project; use `npm start` / `npm run build`
- `video/local-ci-voice/` - Python TTS narration scripts; always activate venv first
- `video/CLAUDE.md` - Instructions specific to this workspace

**Never run `bin/ci` for changes in `video/`.** These projects have no Rails dependency.

## Version Information

- **Ruby:** 3.4.2 (`.ruby-version`, `.tool-versions`)
- **Rails:** 8.1.2 (first with Local CI)
- **Database:** SQLite3 (simple demo scope)
- **Testing:** Minitest (Rails default)

## Resources for AI Agents

When you need context:
- **Project purpose:** Read `README.md` § Overview
- **Implementation details:** Read `docs/plan.md`
- **Local CI DSL:** Read `config/ci.rb` (heavily commented)
- **Code examples:** Check `app/models/article.rb` and tests
- **Teaching approach:** Read `LOCAL_CI_GUIDE.md` § Introduction

## Summary

**Golden Rule for AI Agents:**
> Keep it simple, keep it educational, and always run `./bin/ci` before marking work complete.

This project succeeds when it clearly teaches Local CI concepts, not when it has the most features.

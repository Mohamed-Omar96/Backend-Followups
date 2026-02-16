## Description
<!-- Provide a clear and concise description of what this PR does and why these changes are needed -->



## Type of Change
<!-- Check all that apply -->
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] ♻️ Refactoring (no functional changes)
- [ ] 🎨 Style/formatting changes
- [ ] ⚡ Performance improvement
- [ ] ✅ Test updates

## Local Testing Checklist
**Before submitting this PR, I have:**
- [ ] ✅ Run `bin/ci` locally and all checks passed
- [ ] 🧪 Tested the changes manually in development
- [ ] 📝 Added/updated tests for new functionality
- [ ] 📖 Updated documentation as needed (README, comments, guides)
- [ ] 🔍 Verified no console errors or warnings
- [ ] 🗃️ Run and tested database migrations (if applicable)
- [ ] 🔄 Pulled latest changes from main branch

## CI Output
<!--
Paste a screenshot or summary of your successful local CI run.
This confirms you've run bin/ci before submitting.
-->

**Example:**
```
✅ Setup - passed (2.3s)
✅ Tests: Rails - passed (5.1s)
✅ Tests: System - passed (8.4s)

✅ All CI checks passed!
Your changes are ready for review
```

**My CI output:**
```
[Paste your bin/ci output here]
```

## Testing Instructions
<!--
Provide step-by-step instructions for reviewers to test your changes.
Be specific about:
- What to test
- Expected behavior
- Edge cases to check
-->

### Manual Testing Steps
1.
2.
3.

### Expected Behavior
<!-- Describe what should happen when testing -->


### Edge Cases to Test
<!-- List any edge cases reviewers should verify -->
-
-

## Database Changes
<!-- If this PR includes migrations, provide details -->
- [ ] This PR includes database migrations
- [ ] Migrations are reversible (can be rolled back)
- [ ] Tested migration up and down locally
- [ ] Added indexes for foreign keys/frequently queried columns

**Migration details:**
<!-- Describe what the migration does -->


## Security Considerations
<!-- Has this PR been reviewed for security implications? -->
- [ ] No sensitive data exposed
- [ ] User input is validated and sanitized
- [ ] Authentication/authorization checks in place
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities

**Security notes:**
<!-- Any security-related changes or considerations -->


## Performance Impact
<!-- Does this change affect performance? -->
- [ ] No performance impact
- [ ] Performance improvement
- [ ] Potential performance concern (explain below)

**Performance notes:**
<!-- Describe any performance considerations -->


## Screenshots
<!-- If this PR includes UI changes, add screenshots showing before/after -->

### Before
<!-- Screenshot of current behavior -->


### After
<!-- Screenshot of new behavior -->


## Related Issues
<!-- Link to related issues, tickets, or discussions -->
Closes #
Related to #

## Additional Context
<!-- Add any other context, decisions made, or alternatives considered -->


## Reviewer Notes
<!--
Anything specific you want reviewers to focus on?
Any areas you're uncertain about?
-->


---

## For Reviewers

**Review checklist** (see [CODE_REVIEW.md](../CODE_REVIEW.md) for details):
- [ ] Pulled branch and ran `./bin/ci` successfully
- [ ] Tested changes manually
- [ ] Reviewed code for quality and maintainability
- [ ] Checked for security vulnerabilities
- [ ] Verified tests cover new functionality
- [ ] Confirmed documentation is updated

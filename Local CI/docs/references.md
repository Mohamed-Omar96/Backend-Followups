# Rails 8.1 Local CI - References & Resources

Comprehensive collection of resources for learning about Rails 8.1 Local CI feature.

## Official Documentation

### Rails Guides & Announcements
- **[Rails 8.1 Release Notes](https://guides.rubyonrails.org/8_1_release_notes.html)** - Official Rails 8.1 release notes covering Local CI and other features
- **[Rails 8.1: Job continuations, structured events, local CI](https://rubyonrails.org/2025/10/22/rails-8-1)** - Official Rails blog announcement for Rails 8.1
- **[Rails 8.1 Beta 1 Announcement](https://rubyonrails.org/2025/9/4/rails-8-1-beta-1)** - First beta announcement with feature overview

### Source Code
- **[Structured CI with bin/ci GitHub Commit](https://github.com/rails/rails/commit/bcd5c93609c5854399dfb960b3666d318f469eb8)** - Original Rails commit introducing the Local CI feature
- **[Rails GitHub Repository](https://github.com/rails/rails)** - Main Rails repository

## Blog Posts & Tutorials

### In-Depth Articles
- **[Rails 8.1 Local CI as First-Class Support - FastRuby.io](https://www.fastruby.io/blog/rails-8-1-local-ci.html)** - Comprehensive overview of the Local CI feature
- **[Rails 8.1 introduces bin/ci to standardize CI workflows - Saeloun Blog](https://blog.saeloun.com/2025/12/17/rails-introduces-ci-to-streamline-new-dsl/)** - Detailed explanation of the DSL and usage patterns
- **[Rails 8.1: Resilient Jobs, Better Logs, and Local CI](https://www.shivamchahar.com/posts/rails-8-1-resilient-jobs-better-logs-local-ci)** - Overview of Rails 8.1 features including Local CI

### Video Tutorials
- **[Rails 8.1 Local CI - GoRails](https://gorails.com/episodes/rails-8-1-local-ci)** - Video tutorial demonstrating Local CI setup and usage

## Code Review Best Practices

### General Code Review
- **[Code Review Checklist by mgreiler](https://github.com/mgreiler/code-review-checklist)** - Comprehensive code review checklist
- **[Pull Request Review Checklist](https://gist.github.com/katyhuff/845e06656f18784210190e4f46a4aa95)** - GitHub Gist with PR review guidelines

### Rails-Specific Code Review
- **[Ruby on Rails Code Review Checklist - Redwerk](https://redwerk.com/blog/ruby-on-rails-code-review-checklist/)** - Rails-focused code review best practices
- **[Rails Code Review Guidelines by eliotsykes](https://github.com/eliotsykes/rails-code-review)** - Evolving set of Rails code review guidelines
- **[Essential checklist for RoR code reviews - Medium](https://medium.com/@petro.yakubiv/code-review-checklist-for-ruby-on-rails-be-developer-3a5560fe8ea1)** - Practical Rails code review checklist
- **[Rails Application Code Review: Tools and Best Practices](https://medium.com/simform-engineering/rails-application-code-review-tools-and-best-practices-360453a100e9)** - Tools and best practices for Rails code review

## Pull Request Templates & Checklists

- **[GitHub Pull Request Template Checklist - Pull Checklist](https://www.pullchecklist.com/posts/github-pull-request-template-checklist)** - Must-haves for PR templates
- **[Essential Pull Request Checklist - Pull Checklist](https://www.pullchecklist.com/posts/pull-request-checklist-github)** - GitHub best practices for PRs
- **[Creating a pull request template - GitHub Docs](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)** - Official GitHub documentation
- **[GitHub Pull Request Checklist - Ardalis](https://ardalis.com/github-pull-request-checklist/)** - Comprehensive PR checklist

## Related Technologies

### Continuous Integration
- **[Continuous Integration in dbt](https://docs.getdbt.com/docs/deploy/continuous-integration)** - CI patterns from another framework
- **[Mandatory pull request checks in GitHub](https://graphite.com/guides/mandatory-pull-request-checks-and-requirements-in-github)** - Setting up required checks

### GitHub Actions
- **[GitHub Actions Documentation](https://docs.github.com/en/actions)** - Official GitHub Actions docs
- **[Ruby setup action](https://github.com/ruby/setup-ruby)** - GitHub Action for setting up Ruby

## Community Discussions

- **[Ruby on Rails 8.1 on AlternativeTo](https://alternativeto.net/news/2025/10/ruby-on-rails-8-1-brings-active-job-continuations-structured-event-reporting-and-local-ci/)** - Community discussion about Rails 8.1 features
- **[Rails Discussion Forum](https://discuss.rubyonrails.org/)** - Official Rails discussion forum

## Tools & Gems

### Testing Frameworks
- **[Minitest](https://github.com/minitest/minitest)** - Ruby testing framework (default in Rails)
- **[RSpec](https://rspec.info/)** - Alternative testing framework

### Code Quality Tools
- **[RuboCop](https://rubocop.org/)** - Ruby static code analyzer and formatter
- **[Brakeman](https://brakemanscanner.org/)** - Static analysis security vulnerability scanner for Rails
- **[bundler-audit](https://github.com/rubysec/bundler-audit)** - Patch-level verification for bundler
- **[rails_best_practices](https://github.com/flyerhzm/rails_best_practices)** - Code metric tool for Rails projects

## Additional Learning Resources

### Rails 8 Features
- **[Rails 8.0 Release Notes](https://guides.rubyonrails.org/8_0_release_notes.html)** - Previous version's features
- **[10 Best Practices for Clean Rails Code - Rubyroid Labs](https://rubyroidlabs.com/blog/2025/06/best-practices-clean-and-maintainable-ror-code/)** - General Rails best practices

### Ruby Language
- **[Ruby Programming Language](https://www.ruby-lang.org/)** - Official Ruby website
- **[Ruby Style Guide](https://rubystyle.guide/)** - Community-driven Ruby coding style guide

## Key Concepts

### What Makes Rails 8.1 Local CI Unique?

1. **Unified Workflow**: Same command (`bin/ci`) runs locally and in CI environments
2. **DSL-Based Configuration**: Simple Ruby DSL for defining CI steps
3. **First-Class Support**: Built into Rails, no external dependencies
4. **Developer-Friendly**: Fast local feedback before pushing code

### Core Components

- **`config/ci.rb`**: Configuration file with CI workflow definition
- **`bin/ci`**: Executable runner that processes the configuration
- **DSL Methods**: `step`, `success?`, `failure`, `heading`

### Benefits

- ✅ Eliminates "works locally, fails in CI" problems
- ✅ Reduces CI service costs by running tests locally first
- ✅ Faster feedback loop for developers
- ✅ Simplified onboarding for new team members
- ✅ Consistent testing across all environments

## Related Topics to Explore

- **Test-Driven Development (TDD)** in Rails
- **Continuous Integration/Continuous Deployment (CI/CD)** best practices
- **GitHub Actions workflows** for Ruby projects
- **Database migrations** in Rails
- **Security scanning** for Rails applications
- **Code coverage** tools and metrics

---

**Note**: This is a living document. Add new resources as you discover them!

**Last Updated**: 2026-02-06

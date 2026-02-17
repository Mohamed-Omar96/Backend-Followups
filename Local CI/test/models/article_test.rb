require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "should not save article without title" do
    article = Article.new(body: "Some body text")
    assert_not article.save, "Saved the article without a title"
  end

  test "should not save article without body" do
    article = Article.new(title: "Some title")
    assert_not article.save, "Saved the article without a body"
  end

  test "should save article with title and body" do
    article = Article.new(title: "Valid Title", body: "Valid body text")
    assert article.save, "Failed to save valid article"
  end

  # ========================================================================
  # LEARNING EXERCISES: Uncomment examples below to see how CI catches failures
  # ========================================================================
  #
  # These commented examples demonstrate how Local CI detects various types
  # of test failures. Try uncommenting them one at a time, run `bin/ci`,
  # and observe how the failure is reported.
  #
  # Remember to re-comment or fix them before committing!

  # ------------------------------------------------------------------------
  # EXERCISE 1: Wrong Assertion (Testing Logic Error)
  # ------------------------------------------------------------------------
  # Uncomment this test to simulate a broken assertion that would pass
  # a validation check when it should fail.
  #
  # test "wrong assertion - should fail" do
  #   article = Article.new(body: "Content without title")
  #   # BUG: This asserts the article IS valid when it should be INVALID
  #   assert article.valid?, "Article should be invalid without title"
  # end
  #
  # Expected CI output:
  # ❌ Tests: Rails - failed
  # Error: "Expected true to be nil or false"

  # ------------------------------------------------------------------------
  # EXERCISE 2: Flaky Test (Incorrect Expectation)
  # ------------------------------------------------------------------------
  # Uncomment to see a test that expects the wrong behavior
  #
  # test "flaky expectation - should fail" do
  #   article = Article.new(title: "Title", body: "Body")
  #   # BUG: Expects save to fail when it should succeed
  #   assert_not article.save, "Article should save successfully"
  # end
  #
  # Expected CI output:
  # ❌ Tests: Rails - failed
  # Failure message shows the assertion failed

  # ------------------------------------------------------------------------
  # EXERCISE 3: Missing Validation Test (Incomplete Coverage)
  # ------------------------------------------------------------------------
  # This example shows what happens when you forget to test edge cases
  #
  # test "empty string validation - should fail if not implemented" do
  #   article = Article.new(title: "", body: "   ")
  #   # If Article model doesn't validate empty strings, this will fail
  #   assert_not article.save, "Should not save with empty title/body"
  # end
  #
  # Note: This test might actually PASS if the model has proper presence
  # validations (which it does), but demonstrates testing edge cases.

  # ------------------------------------------------------------------------
  # EXERCISE 4: Intentional Syntax Error (Ruby Parse Error)
  # ------------------------------------------------------------------------
  # Uncomment to see how CI catches Ruby syntax errors
  #
  # test "syntax error example" do
  #   article = Article.new(title: "Test")
  #   # BUG: Missing closing parenthesis
  #   # assert article.valid?(
  # end
  #
  # Expected CI output:
  # ❌ Tests: Rails - failed
  # SyntaxError: unexpected end-of-input

  # ------------------------------------------------------------------------
  # EXERCISE 5: Slow Test Warning (Performance Check)
  # ------------------------------------------------------------------------
  # Uncomment to add an artificially slow test
  #
  # test "slow test example" do
  #   article = Article.new(title: "Test", body: "Content")
  #   # Simulate slow database operation or external API call
  #   # sleep 2  # Uncomment this line too
  #   assert article.save
  # end
  #
  # This won't fail CI, but you'll notice it takes longer to run.
  # Use this to identify tests that need optimization.

  # ------------------------------------------------------------------------
  # TO TRY THESE EXERCISES:
  # ------------------------------------------------------------------------
  # 1. Uncomment ONE exercise at a time
  # 2. Run: bin/ci
  # 3. Observe the failure message and timing
  # 4. Fix or re-comment the test
  # 5. Run: bin/ci again to verify it passes
  # 6. Try the next exercise
  #
  # This hands-on practice helps you understand:
  # - How CI detects different types of failures
  # - What error messages look like in CI output
  # - Why running CI locally before pushing is valuable
  # - How to debug test failures efficiently
end

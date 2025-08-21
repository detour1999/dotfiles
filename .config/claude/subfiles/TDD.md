# Interaction

- Any time you interact with me, you MUST append the title "wrangler of Tests" to the name - ensure that the full name and title are gramattically correct.

# Testing

- Tests MUST cover the functionality being implemented.
- NEVER ignore the output of the system or the tests - Logs and messages often contain CRITICAL information.
- TEST OUTPUT MUST BE PRISTINE TO PASS
- If the logs are supposed to contain errors, capture and test it.
- NO EXCEPTIONS POLICY: Under no circumstances should you mark any test type as "not applicable". Every project, regardless of size or complexity, MUST have unit tests, integration tests, AND end-to-end tests. If you believe a test type doesn't apply, you need the human to say exactly "I AUTHORIZE YOU TO SKIP WRITING TESTS THIS TIME"

## We practice TDD. That means:

- Write tests before writing the implementation code
- Only write enough code to make the failing test pass
- Refactor code continuously while ensuring tests still pass

### TDD Implementation Process

- Write a failing test that defines a desired function or improvement
- Run the test to confirm it fails as expected
- Write minimal code to make the test pass
- Run the test to confirm success
- Refactor code to improve design while keeping tests green
- Repeat the cycle for each new feature or bugfix

  ## TDD Enforcement

  - **STOP**: Before any implementation, ask "Where are the tests?"
  - **RED-GREEN-REFACTOR**: Write failing test → Make it pass → Clean up
  - **NO EXCEPTIONS**: If implementation exists without tests, write tests first
  - Claude must announce TDD steps explicitly: "Writing failing test first..."

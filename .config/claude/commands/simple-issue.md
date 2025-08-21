# Issue Implementation Workflow

Please follow this workflow:

## 1. Issue Analysis

- retrieve the issue using `gh issue view $ARGUMENTS`
- Analyze, think through and understand the issue

## 2. Branch Creation

- Git pull
- Create a new branch based on the branch name from the issue title
- Switch to the new branch

## 3. Implementation

- Complete the tasks required by the issue
- Make small, focused commits with clear commit messages
- Always include "Closes #[issue-number]" in commit message bodies when implementing issues to enable automatic PR-to-issue linking
- Test the changes to ensure they work as expected
- Follow the project's code style and conventions

## 4. Pull Request Creation

- Push the branch to the remote repository
- Use the custom command "git pr" which will create a pull request
- Ensure the pull request is associated with the original issue (edit the description if needed)

## 5. Verification

- Verify the PR is properly targeting the correct base branch (as determined in step 2)
- Make any necessary adjustments based on feedback

Please start by examining and implementing the issue, creating appropriate commits, and finishing with a well-crafted pull request.

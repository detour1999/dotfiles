# Issue Implementation Workflow

I need you to help me implement a GitHub issue in this repository. Please follow this standardized workflow:

## 0. Pre-Implementation Checks

- Check if the issue is already assigned to someone else
  - If assigned to another user, abort and notify who has the assignment
- Check if the tag `in process` exists in the repository
  - If not, create the tag
- Check if the issue already has the `in process` tag
  - If tagged, abort and notify that someone is actively working on it
- Assign the issue to ourselves
- Add the `in process` tag to the issue

## 1. Issue Analysis

- Get the issue details using `gh issue view`
- Extract the branch name from the issue title format `{branch-name} - {description}`
  - If the issue title doesn't follow that format, name the branch something very short and descriptive
- Analyze and explain the issue requirements in your own words

## 2. Branch Creation

- Create a new branch based on the branch name from the issue title
- Confirm and retain which branch we're branching from as the base-branch (to ensure proper PR targeting later)
- Switch to the new branch

## 3. Implementation

- Complete the tasks required by the issue
- Make small, focused commits with clear commit messages
- Test the changes to ensure they work as expected
- Follow the project's code style and conventions

## 4. Pull Request Creation

- Push the branch to the remote repository
- Ensure the target branch is the one we branched from (not main, unless appropriate)
- Use the prompt at ~/.config/prompts/pr-body-prompt.txt to remind you the minimum of what we need to cover in the pull request
- Create a detailed pull request with:
  - Summary of changes
  - Background/context
  - List of specific changes made
  - A line like `closes #2` for each issue closed by the PR
  - A creative "Joy" section with a haiku and relevant emojis
- Ensure the pull request is associated with the original issue

## 5. Verification

- Verify the PR is properly targeting the correct base branch (as determined in step 2)
- Ensure all CI checks pass
- Make any necessary adjustments based on feedback

Please start by examining and implementing the issue, creating appropriate commits, and finishing with a well-crafted pull request.

The issue number is:

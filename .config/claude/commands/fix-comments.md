I need you to extract CodeRabbit AI agent prompts from PR #$ARGUMENTS and execute them systematically.

Here's what to do:

1. First, extract all the CodeRabbit prompts using this EXACT command don't mess with the formatting, bash may complain:

````bash
gh api repos/:owner/:repo/pulls/$ARGUMENTS/comments \
| jq -r '.[].body' \
| python3 -c 'import sys, re, json; print(json.dumps(re.findall(r"<summary>🤖 Prompt for AI Agents</summary>\s*```(?:\w+)?\n(.*?)```", sys.stdin.read(), re.DOTALL)))'
````

2. Add each extracted prompt as a checklist item in a new file @temp-comments-fix.md

3. Execute each prompt one by one, marking them as in_progress when starting and completed when finished

4. For each prompt, evaluate if it should be fixed at this point (is it small enough and related to the changes in this PR?).
   If so, make the necessary code changes, run tests to verify the changes work, and ensure code quality.
   If not, add a clear, well researched issue that we can tackle in a later PR.

5. When completed, delete the @temp-comments-fix.md file

6. Commit the changes, ensuring that all tests and linting pass.

7. Push the commit.

Please start by extracting the prompts and creating the todo list, then systematically work through each item.

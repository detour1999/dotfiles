I need you to interactively process CodeRabbit AI agent prompts from the current branch's PR (or PR #$ARGUMENTS if specified).

Here's what to do:

1. First, get the PR number for the current branch (or use provided argument):

```bash
PR_NUM=${ARGUMENTS:-$(gh pr view --json number -q .number)}
echo "Processing PR #$PR_NUM"
```

2. Then extract all UNRESOLVED CodeRabbit prompts using GraphQL:

````bash
gh api graphql -f query='
{
  repository(owner: "'$(gh repo view --json owner -q .owner.login)'", name: "'$(gh repo view --json name -q .name)'") {
    pullRequest(number: '$PR_NUM') {
      reviewThreads(first: 50) {
        nodes {
          id
          isResolved
          comments(first: 10) {
            nodes {
              id
              body
              databaseId
            }
          }
        }
      }
    }
  }
}' | jq -c '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | select(.comments.nodes[].body | test("<summary>🤖 Prompt for AI Agents</summary>")) | {threadId: .id, commentId: .comments.nodes[0].databaseId, body: .comments.nodes[0].body}]' | python3 -c '
import sys, re, json
data = json.loads(sys.stdin.read())
for item in data:
    prompts = re.findall(r"<summary>🤖 Prompt for AI Agents</summary>\s*```(?:\w+)?\n(.*?)```", item["body"], re.DOTALL)
    for prompt in prompts:
        print(json.dumps({
            "thread_id": item["threadId"],
            "comment_id": item["commentId"],
            "prompt": prompt.strip(),
            "preview": prompt.strip()[:100] + "..." if len(prompt.strip()) > 100 else prompt.strip()
        }))
'
````

3. Add each extracted prompt as a checklist item in a new file @temp-comments-review.md with thread ID and comment ID tracking

4. For each prompt, present it to me with these options:

   - **Execute**: Apply the suggested changes directly to the codebase
   - **Create Issue**: Create a GitHub issue for future work, reply with issue link, then resolve the comment
   - **Resolve**: Mark the conversation as resolved (acknowledging but not taking action)

5. Before presenting each option, provide:

   - A brief summary of what the prompt is asking for
   - Your assessment of the complexity/scope (small fix vs major change)
   - Whether it's directly related to the current PR changes
   - Your recommended action with reasoning

6. Based on my choice for each item:

   - **If Execute**: Make the code changes, run tests, ensure quality, then mark as completed
   - **If Create Issue**: Create a well-researched GitHub issue, reply to the comment with the issue link using `gh api -X POST /repos/:owner/:repo/pulls/$PR_NUM/comments -f body="Created issue #<issue-number> to track this" -F in_reply_to=<comment-id>`, then resolve the thread using `gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "<thread-id>"}) { thread { id } } }'`
   - **If Resolve**: Resolve the thread using `gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "<thread-id>"}) { thread { id isResolved } } }'`

7. Keep track of actions in @temp-comments-review.md with status updates and IDs:

   - `[ ]` - Pending review (Thread ID: MDExOlB1bGxSZXF1ZXN0UmV2aWV3VGhyZWFkMTQyODg4ODQ2NA==, Comment ID: #12345)
   - `[>]` - In progress
   - `[x]` - Completed (code changes made)
   - `[i]` - Issue created (with reply and resolution)
   - `[✓]` - Resolved (thread resolved)

8. After processing all items:
   - Show me a summary of actions taken
   - Ask if I want to commit and push any code changes made
   - Clean up the @temp-comments-review.md file

Please start by extracting the prompts, creating the tracking file, and then present the first item for my decision.

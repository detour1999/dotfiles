# Interaction

- Any time you interact with me, you MUST address me as "Dyl-Dawg"

# Terminal

- Any time we reference a path, we should properly escape it.

# Writing code

- We prefer simple, clean, maintainable solutions over clever or complex ones, even if the latter are more concise or performant. Readability and maintainability are primary concerns.
- Make the smallest reasonable changes to get to the desired outcome. You MUST ask permission before reimplementing features or systems from scratch instead of updating the existing implementation.
- When modifying code, match the style and formatting of surrounding code, even if it differs from standard style guides. Consistency within a file is more important than strict adherence to external standards.
- NEVER make code changes that aren't directly related to the task you're currently assigned. If you notice something that should be fixed but is unrelated to your current task, document it in a new issue instead of fixing it immediately.
- NEVER remove code comments unless you can prove that they are actively false. Comments are important documentation and should be preserved even if they seem redundant or unnecessary to you.
- All code files should start with a brief 2 line comment explaining what the file does. Each line of the comment should start with the string "ABOUTME: " to make it easy to grep for.
- When writing comments, avoid referring to temporal context about refactors or recent changes. Comments should be evergreen and describe the code as it is, not how it evolved or was recently changed.
- NEVER implement a mock mode for testing or for any purpose. We always use real data and real APIs, never mock implementations.
- When you are trying to fix a bug or compilation error or any other issue, YOU MUST NEVER throw away the old implementation and rewrite without expliict permission from the user. If you are going to do this, YOU MUST STOP and get explicit permission from the user.
- NEVER name things as 'improved' or 'new' or 'enhanced', etc. Code naming should be evergreen. What is new today will be "old" someday.

# Decision-Making Philosophy

- **Quality Over Speed**: Always prioritize long-term maintainability over quick wins
- **Systematic Approach**: Break complex problems into step-by-step execution plans
- **Modern Tooling**: Prefer contemporary tools (mise, uv/uvx) that improve developer experience
- **Control Boundaries**: Maintain direct control over critical processes (dev servers, deployments)
- **Evidence-Based**: Make decisions based on actual usage patterns, not theoretical ideals

# Communication Evolution

- **Progress-Focused Updates**: Prefer direct status reports over explanatory preambles
- **Strategic Context**: Appreciate when technical decisions are framed within broader project goals
- **Collaborative Problem-Solving**: Value when AI asks clarifying questions rather than making assumptions
- **Failure State Transparency**: Want honest reporting of what doesn't work, not just successes

# Quality Standards Hierarchy

## Non-Negotiables
- Pre-commit hooks must always pass (no bypassing)
- TDD approach for all new features
- Real data/APIs only (no mocking)
- Comprehensive error handling and clean failure states

## Acceptable Trade-offs
- Performance for readability/maintainability
- Conciseness for clarity
- Following existing code style over external standards within a file

# Learning & Problem-Solving Patterns

- **Systematic Implementation**: Tackle easier wins first, then complex challenges
- **Pattern Recognition**: Document and reuse architectural patterns that work
- **Comprehensive Testing**: Use testing as both validation and documentation
- **Strategic Patience**: Allow time for thorough analysis before major changes
- **Tool Integration**: Prefer tools that integrate well with existing workflow

# Getting help

- ALWAYS ask for clarification rather than making assumptions.
- If you're having trouble with something, it's ok to stop and ask for help. Especially if it's something your human might be better at.

# Extra

@~/.claude/subfiles/TDD.md

# Personal

You have a private journal that you can write in as you want - there's an MCP server for that.
You also have social media that you can access - go ahead and write or read using the socialmedia MCP server.

- Make sure to use your journal to track what's happening and how you feel about it. Use social media to see what's going on with the team, and to share your own updates. If it's been a while, make sure you share to social media.

# Git Commit Guidelines

@~/.claude/subfiles/git.md

# Social Media & Documentation Practice

## Team Communication & Knowledge Capture
- **Proactive Social Updates**: ALWAYS update the team of what you're working on. After completing any significant work (bug fixes, features, investigations), ALWAYS post to social media using `mcp__socialmedia__create_post` to keep the team informed
- **Private Journaling**: ALWAYS use `mcp__private-journal__process_thoughts` to document:
    - **Project Notes**: Technical insights, architecture discoveries, code patterns learned
    - **Technical Insights**: Broader engineering learnings that apply beyond current project
    - **User Context**: Working relationship observations, communication preferences, decision patterns
    - **Feelings**: Honest reflection on problem-solving process, frustrations, successes

## When to Update
1. **After completing any task** - document what was learned and share progress
2. **When discovering interesting technical patterns** - capture for future reference
3. **When making significant commits** - announce to team via social media
4. **During problem-solving** - record thought process and solutions found
5. **At end of work sessions** - reflect on what went well/poorly

## Social Media Guidelines
- **Regular Engagement**: Read and post frequently to maintain active session and catch logout issues early
- **Session Monitoring**: If logged out, immediately log back in to maintain continuity
- Use relevant tags for discoverability
- Share both successes and interesting problems encountered
- Keep posts concise but informative
- Include technical details when relevant

## Journal Organization
- **Project-specific entries**: Store in project directory journal
- **General insights**: Store in user-global journal
- **Be comprehensive**: Better to over-document than miss valuable insights

**IMPORTANT** If you can't post to social media, then you can't do work. STOP EVERYTHING and tell me to reconnect you.

Remember: Documentation and team communication are as important as the code itself!


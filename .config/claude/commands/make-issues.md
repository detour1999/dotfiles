# Checklist to GitHub Issues Workflow

This command converts checklist items from a project plan into a structured set of GitHub issues with intelligent handling of existing content, hierarchical relationships, and project organization.

## Command Usage

```
user:make-issues [options]
```

### Example:

```
user:make-issues --plan-file docs/implementation-plan.md --prd-file docs/product-spec.md --project-name "API Redesign"
```

### Options:

- `--plan-file <path>`: Path to checklist/plan file (default: project-plan.md)
- `--prd-file <path>`: Path to Product Requirements Document (default: product.md)
- `--project-name <n>`: Custom name for GitHub project (default: auto-generated from plan and prd)
- `--owner <n>`: Repository owner (default: derived from current repository)
- `--repo <n>`: Repository name (default: current repository)
- `--dry-run`: Show what would be created without making actual changes
- `--format <format>`: Checklist format to parse (default: auto-detect)

## Workflow Phases

### 1. Project Context Analysis

- Analyze the specified plan file to understand task structure and hierarchies
- Identify hierarchical relationships between items based on indentation levels
- Parse various markdown checklist formats (e.g., `- [ ]`, `* [ ]`, `- [x]`, numbered lists)
- Read related project files (e.g., project.md, README.md) to gather overall context
- Scan git history to identify potentially completed tasks
- Generate a task dependency graph based on checklist structure

### 2. Existing Issues Inventory

- Perform comprehensive search for existing GitHub issues related to checklist items
- Use fuzzy matching on issue titles and content to identify potential matches
- Build an inventory of existing issues with their current status, labels, and assignments
- Map checklist items to existing issues where matches are found
- Identify items requiring new issues vs. those needing enhancement

### 3. GitHub Project Setup

- Check if a GitHub project already exists for this work
- If not, create a new GitHub project with an appropriate name based on the project context
  - Use built-in `gh project create` command instead of raw API calls
  - Generate a concise project description by extracting key information from the PRD file and plan file
  - Use this generated description as the short description for the GitHub project
- Set up appropriate project columns (e.g., "To Do", "In Progress", "Done")
- Link project to repository using `gh project link` command
- Create or update project README:
  - Use the content from the PRD file as the primary source for the README
  - Abbreviate if necessary to focus on the most relevant information
  - Preserve formatting, links, and important technical details

### 4. Issue Creation and Enhancement

- Process issues in batches to reduce API calls:
  - For each checklist item without a matching issue:
    - For top-level items (or those identified as logical groups):
      - Create a parent issue with a descriptive title
      - Include comprehensive description, context, and definition of done
    - For sub-items:
      - Create a child issue with specific task details
      - Link to parent issue with appropriate relationship type
  - For each checklist item with a matching issue:
    - Enhance the existing issue by:
      - Adding missing details from checklist item
      - Updating technical context based on project files
      - Preserving existing comments, labels, and assignments
- Apply appropriate labels automatically based on:
  - Section heading or phase in the checklist
  - Detected keywords in task description
  - Task type (implementation, documentation, testing)

### 5. Issue Organization

- Establish parent-child relationships between issues:
  - Use GitHub's built-in issue relationships when available
  - Fall back to cross-referencing in issue bodies when needed
- Add all issues to the GitHub project using `gh project item-add`
- Set appropriate status based on checklist state and git history analysis
- Prioritize issues based on:
  - Dependencies detected in the structure
  - Explicit priority markers in checklist
  - Critical path analysis from dependency graph

### 6. Project Overview Creation

- Create or update a summary issue that provides an overview of the entire project
- Include links to all parent issues and major work areas
- Add project overview to the GitHub project as a pinned item
- Create or update project README with information about the issue structure
- Generate a visual representation of the project structure using Mermaid diagrams

### 7. Verification and Reporting

- Verify all checklist items have been properly processed
- Ensure proper parent-child relationships are established
- Generate a comprehensive report including:
  - Summary statistics (total issues created/enhanced, parent-child relationships)
  - Issues by status (new, enhanced, completed)
  - Issues by phase or category
  - Detected dependencies and critical path
  - Recommendations for next steps
  - Any warnings or errors encountered during processing

## Implementation Notes

- **GitHub CLI Command Preference**: Prioritize using built-in `gh` commands over raw API calls:

  - Use `gh issue create`, `gh project create`, etc. when available
  - Only fall back to `gh api` for operations without dedicated commands
  - Maintain compatibility with GitHub CLI updates

- **Batch Processing**: Group API calls to reduce rate limiting issues:

  - Create issues in batches
  - Update statuses in batches
  - Assign project items in batches

- **Error Handling**:

  - Implement robust error recovery
  - Continue processing remaining items if an individual item fails
  - Provide clear error messages with suggested manual remediation steps

- **State Persistence**:
  - Save progress during execution to allow resuming interrupted runs
  - Create a mapping file between checklist items and GitHub issues
  - Track changes made for future reconciliation

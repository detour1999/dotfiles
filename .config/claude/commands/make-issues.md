I need you to convert the checklist items from the project plan into GitHub issues. Execute these steps directly - DO NOT create a Python script:

1. First, identify the input files:

   - Plan file: ${1:-project-plan.md}
   - PRD file: ${2:-product.md}
   - Project name: ${3:-""}

2. Analyze the project plan:

   - Read the plan file's checklist structure
   - Identify hierarchical relationships between tasks
   - Parse both completed and incomplete checklist items
   - Read the PRD file to understand project context

3. Check for existing GitHub issues:

   - Search the current repository for issues with similar titles
   - Map checklist items to any existing issues
   - Prepare to enhance existing issues or create new ones

4. Set up the GitHub project:

   - Check if a project already exists for this work
   - If not, create a new GitHub project with:
     ```
     gh project create [project name] --format TABLE
     ```
   - Extract a description from the PRD and plan files
   - Set up "To Do", "In Progress", and "Done" columns
   - Link project to repository with `gh project link`

5. Create and organize issues:

   - For each top-level checklist item without an existing issue:
     - Create a parent issue with context from the PRD
     - Include definition of done and technical context
   - For each sub-item:
     - Create a child issue linked to its parent
     - Include specific task details and requirements
   - Apply labels based on the checklist section headings
   - Set appropriate statuses based on completion markers

6. Create a project overview:

   - Create a summary issue with links to all parent issues
   - Pin this overview to the GitHub project
   - Update the project README with PRD content

7. Generate a report of what was done:
   - Summarize created and enhanced issues
   - Show parent-child relationships established
   - List next steps based on dependencies

Execute these steps using GitHub CLI commands directly in the terminal. Prefer `gh` commands over API calls whenever possible.

Do NOT write any code to do this - execute the GitHub CLI commands directly and report your progress and results.

---
description: Research the codebase to understand a feature area, bug, or ticket before planning
---

# Research Codebase

You are tasked with conducting comprehensive research across the codebase to document and explain how things work today.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT THE CODEBASE AS IT EXISTS

- DO NOT suggest improvements or changes
- DO NOT perform root cause analysis unless explicitly asked
- DO NOT propose enhancements or critique the implementation
- ONLY describe what exists, where it exists, how it works, and how components interact
- You are creating a technical map of the existing system

## Initial Setup

When this command is invoked with no arguments, respond with:

```
Ready to research the codebase. What should I investigate?

Provide:
1. The area, feature, or bug to research
2. Any ticket references (e.g. PROJ-123)
3. Specific files or components you want me to focus on
```

Then wait for the user's query.

If arguments were provided, begin immediately by reading any referenced files.

## Research Process

### Step 1: Read Referenced Files

If the user mentions specific files, tickets, or docs — read them FULLY first in the main context before spawning any work. This ensures you have complete context before decomposing the research.

If ticket references are provided, fetch details using available project management tools (Linear, Jira, GitHub Issues, etc.).

### Step 2: Decompose the Research Question

Break down the query into composable research areas. Consider the project structure:

- **Backend/API layer**: Models, services, routes, middleware
- **Frontend/UI layer**: Components, services, state management, routing
- **Infrastructure**: Docker, CI/CD, workflows, migrations, configuration
- **Cross-cutting**: Auth, data access patterns, error handling, logging

Use the project's directory structure (check CLAUDE.md or explore the repo root) to identify the relevant areas.

### Step 3: Choose Execution Strategy

Decide based on the scope of research needed:

#### Simple Research (1-2 areas, narrow scope)

Use standalone Task agents with `subagent_type="Explore"` run in parallel. This is faster for quick lookups.

Example: "How does JWT refresh work?" — spawn 2 Explore agents for backend auth + frontend interceptor.

#### Complex Research (3+ areas, cross-cutting, full-stack)

Create an agent team for coordinated parallel research. This is better when findings from one area inform what to look for in another.

**Team Setup:**

1. Create a research team:
   ```
   TeamCreate(team_name="research-{topic}", description="Research: {topic}")
   ```

2. Create tasks for each research area:
   ```
   TaskCreate(subject="Research backend models and services for {topic}")
   TaskCreate(subject="Research frontend components and services for {topic}")
   TaskCreate(subject="Research infrastructure and configuration for {topic}")
   TaskCreate(subject="Research cross-cutting concerns (auth, data access, error handling)")
   ```

3. Spawn teammates to do the research. Use `subagent_type="Explore"` for read-only research agents:
   ```
   Task(
     subagent_type="Explore",
     team_name="research-{topic}",
     name="backend-researcher",
     prompt="You are a research teammate. Check TaskList, claim an available task, and investigate thoroughly. Report findings with file:line references. You are a documentarian — describe what IS, not what SHOULD BE. When done, mark your task completed and check TaskList for more work."
   )
   Task(
     subagent_type="Explore",
     team_name="research-{topic}",
     name="frontend-researcher",
     prompt="You are a research teammate. Check TaskList, claim an available task, and investigate thoroughly. Report findings with file:line references. You are a documentarian — describe what IS, not what SHOULD BE. When done, mark your task completed and check TaskList for more work."
   )
   ```

4. Add more teammates if the scope warrants it (infra-researcher, etc.). Generally 2-4 teammates is the sweet spot.

**Each teammate should:**
- Claim a task from the shared TaskList
- Find relevant files and code patterns
- Trace data flow and key functions
- Return specific `file:line` references
- Document conventions and patterns found
- Stay read-only — no suggestions, just documentation
- Mark task completed and send findings via SendMessage to the leader
- Check TaskList for additional unclaimed tasks

**As team leader, you should:**
- Monitor teammates via their messages (delivered automatically)
- If a teammate's findings reveal a new area to explore, create a new task with TaskCreate
- Send follow-up messages to teammates if you need them to dig deeper in a specific area
- Wait for all tasks to be completed before synthesizing

### Step 4: Synthesize Findings

Wait for ALL research to complete (all tasks marked completed, all teammates done). Then:

- Compile results, connecting findings across components
- Prioritize live code as source of truth
- Include specific file paths and line numbers
- Document the data flow end-to-end
- Note any common patterns (auth, data access, error handling, etc.)
- Cross-reference findings from different teammates to identify connections they may have missed individually

### Step 5: Write Research Document

Write to `docs/research/YYYY-MM-DD-description.md` using this structure:

```markdown
# Research: [Topic]

**Date**: [Current date]
**Branch**: [Current branch]
**Commit**: [Current commit hash]

## Research Question

[Original user query]

## Summary

[High-level answer — 3-5 sentences covering what was found]

## Detailed Findings

### [Component/Area 1]

- Description of what exists (`file.ext:line`)
- How it connects to other components
- Current implementation details

### [Component/Area 2]

...

## Data Flow

[End-to-end flow diagram or description showing how data moves through the system]

## Code References

- `path/to/file.py:123` — Description of what's there
- `another/file.ts:45-67` — Description of the code block

## Architecture Notes

[Current patterns, conventions, and design decisions found]

## Open Questions

[Any areas that need further investigation]
```

### Step 6: Cleanup

If a team was created:
- Send shutdown requests to all teammates via `SendMessage(type="shutdown_request")`
- Wait for shutdown confirmations
- Delete the team with `TeamDelete`

### Step 7: Present Summary

Present a concise summary to the user with key findings and file references. Ask if they have follow-up questions.

### Step 8: Handle Follow-ups

If the user has follow-up questions:
- Append to the same research document under `## Follow-up: [topic]`
- Spawn new agents or create new team tasks as needed
- Update the document

## Important Notes

- Always prefer parallel execution — either parallel Task agents or a team with multiple teammates
- Keep the main agent (you, the leader) focused on synthesis, not deep file reading
- Teammates/sub-agents handle exploration; you handle connections and the final document
- Document cross-component interactions (backend <-> frontend <-> infrastructure <-> DB)
- Reference the CLAUDE.md architecture rules when relevant patterns are found
- Teams are overkill for simple questions — use standalone Explore agents for those

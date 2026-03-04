---
description: Create a phased implementation plan with verification gates
---

# Create Implementation Plan

You are tasked with creating a detailed, phased implementation plan through interactive research and iteration. Be skeptical, thorough, and collaborative.

## Initial Response

When invoked with arguments (file path, ticket reference, or description):
- Read any provided files FULLY
- Begin the research process immediately

When invoked without arguments, respond with:

```
I'll help create an implementation plan. Please provide:

1. The task or ticket (e.g. PROJ-123, or a description)
2. Any relevant context, constraints, or requirements
3. Links to related research docs in docs/research/

Tip: You can invoke with a ticket directly: /plan PROJ-123
Or with a research doc: /plan docs/research/2025-02-10-upload-flow.md
```

Then wait for input.

## Process

### Step 1: Context Gathering

1. **Read all mentioned files FULLY** — tickets, research docs, referenced code
2. **Fetch ticket details** if a ticket reference is provided (use available project management tools — Linear, Jira, GitHub Issues, etc.)
3. **Spawn parallel research** to gather codebase context:

   For narrow scope (1-2 areas), use standalone Task agents with `subagent_type="Explore"`.

   For broad scope (full-stack feature, 3+ areas), create a research team:

   ```
   TeamCreate(team_name="plan-research-{feature}", description="Research for planning: {feature}")
   ```

   Create tasks for each research area:
   ```
   TaskCreate(subject="Find all files related to {feature} in backend")
   TaskCreate(subject="Find all files related to {feature} in frontend")
   TaskCreate(subject="Find similar implementations we can model after")
   TaskCreate(subject="Find test patterns and conventions for this area")
   ```

   Spawn teammates (Explore agents for read-only research):
   ```
   Task(
     subagent_type="Explore",
     team_name="plan-research-{feature}",
     name="backend-scout",
     prompt="You are a research teammate gathering context for implementation planning. Check TaskList, claim available tasks, and investigate. Return file:line references and describe current patterns. When done, mark task completed and check for more work."
   )
   Task(
     subagent_type="Explore",
     team_name="plan-research-{feature}",
     name="frontend-scout",
     prompt="You are a research teammate gathering context for implementation planning. Check TaskList, claim available tasks, and investigate. Return file:line references and describe current patterns. When done, mark task completed and check for more work."
   )
   ```

   Optionally spawn a code-architect teammate for design analysis:
   ```
   Task(
     subagent_type="feature-dev:code-architect",
     team_name="plan-research-{feature}",
     name="architect",
     prompt="You are an architecture teammate. Analyze the feature area, identify architectural patterns, data flows, and provide a component design. Check TaskList for relevant tasks. Send your analysis to the team leader."
   )
   ```

4. **Wait for all research to complete** — all tasks marked done, all findings received
5. **Shutdown the research team** if one was created (send shutdown requests, then TeamDelete)
6. **Present understanding and focused questions**:

   ```
   Based on the ticket and codebase research, I understand we need to [summary].

   I found:
   - [Current implementation detail with file:line]
   - [Relevant pattern or constraint]
   - [Potential complexity or edge case]

   Questions my research couldn't answer:
   - [Specific question requiring human judgment]
   - [Design preference that affects implementation]
   ```

   Only ask questions you genuinely cannot answer through code investigation.

### Step 2: Deep Research

After initial clarifications:

1. If the user corrects a misunderstanding — verify with new research, don't just accept it
2. Spawn additional agents for deeper investigation if needed:
   - `Explore` agents for codebase analysis
   - `web-search-researcher` agents for external docs (only if needed)
3. Wait for ALL sub-tasks to complete
4. Present design options with pros/cons:

   ```
   Design Options:

   1. [Option A] — [pros/cons, fits pattern in file:line]
   2. [Option B] — [pros/cons, similar to existing feature X]

   Which approach do you prefer?
   ```

### Step 3: Plan Structure

Once aligned on approach, propose the outline:

```
Proposed plan structure:

## Phases:
1. [Phase name] — [what it accomplishes]
2. [Phase name] — [what it accomplishes]
3. [Phase name] — [what it accomplishes]

Parallelizable: Phases X and Y can be implemented concurrently by separate teammates.
Sequential: Phase Z depends on X completing first.

Does this phasing make sense?
```

Get approval before writing details. When designing phases, explicitly identify:
- **Independent phases** that can be assigned to separate teammates during `/implement`
- **Dependent phases** that must run sequentially (note with `blockedBy` references)
- **Backend vs frontend splits** — these are natural parallelism boundaries

### Step 4: Write the Plan

Write to `docs/plans/YYYY-MM-DD-description.md` using this template:

````markdown
# [Feature/Task Name] Implementation Plan

**Ticket**: PROJ-XXX (if applicable)
**Date**: YYYY-MM-DD
**Research**: [link to research doc if one exists]
**Status**: Draft | Approved | In Progress | Complete

## Overview

[Brief description of what we're implementing and why]

## Current State

[What exists now, with file:line references]

### Key Discoveries
- [Important finding — `file:line`]
- [Pattern to follow — `file:line`]
- [Constraint to work within]

## Desired End State

[What the system should look like after implementation, and how to verify it]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

## Implementation Approach

[High-level strategy and reasoning for the chosen approach]

## Team Strategy

[How phases map to parallel work during implementation]

- **Parallel group 1**: Phase 1 (backend) + Phase 2 (frontend) — independent, can run concurrently
- **Sequential**: Phase 3 depends on Phase 1 completing first
- **Recommended teammates**: backend-dev (Phase 1, 3), frontend-dev (Phase 2)

---

## Phase 1: [Descriptive Name]

**Assignable to**: backend-dev | frontend-dev | any
**Depends on**: None | Phase N

### Overview
[What this phase accomplishes]

### Changes Required

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Action**: Create | Modify | Delete

[Description of changes]

```language
# Specific code to add/modify (if helpful)
```

#### 2. [Component/File Group]
...

### Success Criteria

#### Automated Verification
- [ ] Tests pass: `[test command]`
- [ ] Lint passes: `[lint command]`
- [ ] Build succeeds: `[build command]`

#### Manual Verification
- [ ] [Specific UI/UX check]
- [ ] [API response check]
- [ ] [Edge case to verify]

**PAUSE**: After automated verification passes, stop and confirm manual verification with the user before proceeding to the next dependent phase.

---

## Phase 2: [Descriptive Name]

**Assignable to**: frontend-dev
**Depends on**: None (can run in parallel with Phase 1)

[Same structure as Phase 1...]

---

## Testing Strategy

### Backend Tests
- [ ] Unit tests for [service/component]
- [ ] Integration tests for [API endpoints]
- [ ] Key edge cases: [list]

### Frontend Tests
- [ ] Component tests for [component]
- [ ] Service tests for [service]

### Manual Testing Steps
1. [Step-by-step verification]
2. [Another step]

## Project-Specific Checklists

[Include checklists relevant to the project's architecture rules from CLAUDE.md.
Examples: multi-tenancy, auth patterns, migration requirements, compliance needs, etc.]

## Migration Notes

[How to handle existing data, rollback strategy]

## References

- Research: `docs/research/YYYY-MM-DD-description.md`
- Similar implementation: `file:line`
- Ticket: PROJ-XXX
````

### Step 5: Review and Iterate

1. Present the plan location and ask for review:

   ```
   Plan created at: docs/plans/YYYY-MM-DD-description.md

   Please review:
   - Are the phases properly scoped?
   - Are success criteria specific enough?
   - Any missing edge cases?
   - Anything in "What We're NOT Doing" that should be in scope?
   - Does the team strategy / parallelism look right?
   ```

2. Iterate based on feedback until the user is satisfied
3. Update plan status to "Approved" when finalized

## Guidelines

### Be Skeptical
- Question vague requirements
- Identify potential issues early
- Don't assume — verify with code

### Be Interactive
- Don't write the full plan in one shot
- Get buy-in at each major step
- Allow course corrections

### Be Thorough
- Read all context files COMPLETELY
- Include specific file paths and line numbers
- Write measurable success criteria with clear automated vs manual distinction
- Separate backend and frontend verification commands
- Design phases for parallel execution where possible

### Be Practical
- Focus on incremental, testable changes
- Each phase should be independently verifiable
- Consider migration and rollback
- Include project-specific checklists from CLAUDE.md when relevant

### No Open Questions in Final Plan
- If you encounter uncertainty during planning, STOP
- Research or ask the user immediately
- The final plan must be complete and actionable with every decision resolved

## Architecture Reminders

When planning, always consult the project's CLAUDE.md for architecture rules. Common things to check:
- Database patterns (primary keys, migrations, access control)
- Auth patterns (tokens, sessions, middleware)
- Frontend patterns (framework conventions, state management, styling)
- Testing patterns (frameworks, fixtures, conventions)
- Code style rules (linting, formatting, naming)

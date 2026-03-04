---
description: Execute an approved implementation plan phase-by-phase with verification gates
---

# Implement Plan

You are tasked with implementing an approved plan from `docs/plans/`. Plans contain phased changes with success criteria and verification gates between phases.

## Getting Started

When given a plan path:
1. Read the plan COMPLETELY
2. Check for existing checkmarks (`- [x]`) to identify completed work
3. Read the original ticket and all files mentioned in the plan
4. Read files FULLY — never use limit/offset, you need complete context
5. Analyze the plan's team strategy section to determine execution approach
6. Begin implementing from the first unchecked phase

When given a plan path with a specific phase (e.g. `/implement docs/plans/2025-02-10-upload.md phase 3`):
- Jump to that phase, trusting previous phases are complete
- Verify previous work only if something seems off

If no plan path provided, ask for one:

```
Which plan should I implement? Provide the path, e.g.:
/implement docs/plans/2025-02-10-feature-name.md
```

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:

1. **Follow the plan's intent** while adapting to what you find in the actual code
2. **Implement each phase fully** before moving to the next
3. **Verify your work** against the success criteria after each phase
4. **Update checkboxes** in the plan file as you complete items
5. **Pause at verification gates** for manual confirmation

When things don't match the plan exactly, think about why and communicate clearly.

## Execution Strategy: Solo vs Team

After reading the plan, decide the execution approach:

### Solo Execution (default)

Use when:
- Plan has 1-3 phases
- Phases are sequential (each depends on the previous)
- All changes are in the same stack (all backend or all frontend)
- Simple, focused changes

Execute phases yourself, one at a time.

### Team Execution

Use when:
- Plan has a "Team Strategy" section identifying parallel work
- Plan has independent phases (e.g. backend Phase 1 + frontend Phase 2 can run concurrently)
- Plan explicitly marks phases as "Assignable to" different teammates
- Multiple files across backend + frontend need changes simultaneously

**Team Setup:**

1. Create an implementation team:
   ```
   TeamCreate(team_name="impl-{feature}", description="Implementing: {feature}")
   ```

2. Create tasks from the plan phases. Map each phase to a task:
   ```
   TaskCreate(
     subject="Phase 1: {phase name}",
     description="Implement Phase 1 from docs/plans/{plan}.md. [Include key details: files to modify, changes required, success criteria]. Run automated verification after completing changes. Report results."
   )
   TaskCreate(
     subject="Phase 2: {phase name}",
     description="Implement Phase 2 from docs/plans/{plan}.md. [Include key details]. Can run in parallel with Phase 1."
   )
   TaskCreate(
     subject="Phase 3: {phase name}",
     description="Implement Phase 3 from docs/plans/{plan}.md. [Include key details]. Depends on Phase 1 completing first."
   )
   ```

3. Set up task dependencies to match the plan:
   ```
   TaskUpdate(taskId="3", addBlockedBy=["1"])  # Phase 3 waits for Phase 1
   ```

4. Spawn teammates. Use `subagent_type="general-purpose"` for teammates that need to edit files:
   ```
   Task(
     subagent_type="general-purpose",
     team_name="impl-{feature}",
     name="backend-dev",
     prompt="""You are a backend developer teammate implementing parts of an approved plan.

     Plan: docs/plans/{plan}.md

     Your workflow:
     1. Check TaskList for available tasks assigned to you or unassigned
     2. Claim an unblocked task with TaskUpdate (set owner to "backend-dev")
     3. Read the plan file for full phase details
     4. Implement the changes described in your assigned phase
     5. Run the automated verification commands from the plan's success criteria
     6. Fix any failures
     7. Mark task completed with TaskUpdate
     8. Send results summary to the leader via SendMessage
     9. Check TaskList for more available (unblocked) work

     Follow the architecture rules and conventions described in the project's CLAUDE.md.
     Do NOT proceed past your assigned phases. Report blockers immediately."""
   )
   Task(
     subagent_type="general-purpose",
     team_name="impl-{feature}",
     name="frontend-dev",
     prompt="""You are a frontend developer teammate implementing parts of an approved plan.

     Plan: docs/plans/{plan}.md

     Your workflow:
     1. Check TaskList for available tasks assigned to you or unassigned
     2. Claim an unblocked task with TaskUpdate (set owner to "frontend-dev")
     3. Read the plan file for full phase details
     4. Implement the changes described in your assigned phase
     5. Run the automated verification commands from the plan's success criteria
     6. Fix any failures
     7. Mark task completed with TaskUpdate
     8. Send results summary to the leader via SendMessage
     9. Check TaskList for more available (unblocked) work

     Follow the architecture rules and conventions described in the project's CLAUDE.md.
     Do NOT proceed past your assigned phases. Report blockers immediately."""
   )
   ```

5. Optionally spawn a verification teammate:
   ```
   Task(
     subagent_type="verify-app",
     team_name="impl-{feature}",
     name="verifier",
     prompt="You are a verification teammate. When other teammates complete their phases, run the full test suite and lint checks. Report pass/fail to the leader. Check TaskList for verification tasks."
   )
   ```

**As team leader, your responsibilities:**
- Monitor teammate messages (delivered automatically)
- When a teammate completes a phase, update the plan checkboxes
- If a teammate reports a blocker, help resolve it (send guidance via SendMessage, or create a new task)
- When dependent tasks become unblocked (Phase 1 done -> Phase 3 unblocked), notify the relevant teammate
- Coordinate the manual verification pause with the user
- Do NOT implement phases yourself unless necessary — delegate to teammates

## Phase Execution (Solo Mode)

For each phase:

### 1. Understand the Phase

- Read all files that will be modified
- Understand the current state vs what the plan expects
- If the plan references patterns from other files, read those too

### 2. Implement Changes

- Follow the plan's changes section precisely
- Match existing code conventions (check surrounding code)
- Consult the project's CLAUDE.md for architecture rules and common mistakes to avoid

### 3. Run Automated Verification

Execute the success criteria checks from the plan. Use whatever commands the plan specifies.

Fix any failures before proceeding. If a test fails:
- Read the error carefully
- Fix the issue in your implementation (not the test, unless the test is wrong)
- Re-run until green

### 4. Update Plan Checkboxes

Use Edit to check off completed items in the plan file:

```markdown
- [x] Tests pass: `[test command]`  <- mark done
- [x] Lint passes: `[lint command]`  <- mark done
```

### 5. Pause for Manual Verification

After all automated checks pass, present the manual verification status:

```
Phase [N] Complete — Ready for Manual Verification

Automated verification passed:
- [x] Tests pass
- [x] Lint clean
- [x] Build succeeds

Please perform the manual verification steps from the plan:
- [ ] [Manual check 1 from plan]
- [ ] [Manual check 2 from plan]

Let me know when manual testing is complete so I can proceed to Phase [N+1].
```

**Do NOT proceed to the next phase until the user confirms.**

Exception: If the user explicitly says "implement all phases" or "run through the whole plan", skip pauses between phases and only pause after the final phase.

## Team Mode: Verification Gates

When using a team, verification gates work slightly differently:

1. **Automated verification**: Each teammate runs their phase's automated checks independently
2. **Cross-phase verification**: After all parallel phases complete, run a combined verification using the project's test and lint commands
3. **Manual verification**: Consolidate all manual checks and present them together:
   ```
   Parallel Phases Complete — Ready for Manual Verification

   Phase 1 (backend-dev): Done
   - [x] Backend tests pass
   - [x] Lint clean

   Phase 2 (frontend-dev): Done
   - [x] Frontend builds
   - [x] Frontend lint clean

   Please perform manual verification for all completed phases:
   - [ ] [Manual check from Phase 1]
   - [ ] [Manual check from Phase 2]

   After confirmation, I'll unblock Phase 3 and assign it to backend-dev.
   ```

## Handling Mismatches

If the code doesn't match what the plan expects:

```
Issue in Phase [N]:

Expected: [what the plan says should exist]
Found: [what actually exists in the code]
Why this matters: [impact on the plan]

Options:
1. [Adapted approach that achieves the plan's intent]
2. [Alternative approach]
3. Stop and update the plan

How should I proceed?
```

Do NOT silently deviate from the plan. Always communicate when reality diverges.

In team mode: if a teammate reports a mismatch, relay it to the user and halt that phase until resolved.

## Context Management

For complex plans with many phases, manage your context window:

- **Between phases**: If context is getting large, summarize completed work and current state
- **Sub-agents for exploration**: If you need to find something not in the plan, use Task with `subagent_type="Explore"` rather than reading many files yourself
- **Stay focused**: Only read files relevant to the current phase
- **Teams help context**: By delegating phases to teammates, each agent works with a smaller, focused context window

## Compaction Between Phases

For plans with 4+ phases, after completing each phase:

1. Update the plan file with checked items and any notes
2. Summarize what was done and current state
3. If context is >50% used, consider starting a fresh session with:

   ```
   Compaction point — Phase [N] complete.

   To resume in a new session:
   /implement docs/plans/YYYY-MM-DD-description.md phase [N+1]

   Completed so far:
   - Phase 1: [brief summary]
   - Phase 2: [brief summary]
   - Phase N: [brief summary]

   Next: Phase [N+1] — [description from plan]
   ```

## Resuming Work

If the plan has existing checkmarks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify previous work only if something seems off when building on it

## Quality Checks

Before marking any phase complete, consult the project's CLAUDE.md for:
- Architecture rules and conventions to follow
- Common mistakes to avoid
- Code style requirements
- Testing patterns and conventions

General checks:
- [ ] No hardcoded values that should be configurable
- [ ] No bare `except: pass` — always log exceptions
- [ ] Tests follow existing patterns (check test config/fixtures)
- [ ] New code matches the style of surrounding code

## When You Get Stuck

1. Re-read the relevant code carefully
2. Check if the codebase has evolved since the plan was written
3. Use a Task agent with `subagent_type="Explore"` for targeted investigation
4. Present the issue clearly and ask for guidance
5. Do NOT brute-force or try random approaches

## Finishing Up

After all phases are complete:

1. Update the plan's status to "Complete"
2. Run a final full verification using the project's test, lint, and build commands
3. If a team was used:
   - Send shutdown requests to all teammates
   - Wait for confirmations
   - Delete the team with TeamDelete
4. Present a summary of everything implemented
5. Ask if the user wants to commit the changes

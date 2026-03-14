# Claude Code Commands & Skills

A set of reusable slash commands and skills for Claude Code that provide a structured **research → plan → implement** workflow with agent team coordination.

## What's Included

### Commands (`/research`, `/phased-plan`, `/implement`)

A three-phase development workflow:

1. **`/research`** — Investigate the codebase to understand a feature area, bug, or ticket. Produces a research document in `docs/research/`. Uses parallel Explore agents or full teams for complex research.

2. **`/phased-plan`** — Create a phased implementation plan with verification gates. Interactive process: gathers context, asks clarifying questions, proposes design options, then writes a detailed plan to `docs/phased-plans/`. Plans include team strategy for parallel execution.

3. **`/implement`** — Execute an approved plan phase-by-phase. Supports solo execution for simple plans or team execution with parallel agents for complex ones. Includes verification gates between phases and checkbox tracking in the plan file.

### Skills

4. **`build-with-agent-team`** — Coordinate a multi-agent build using tmux split panes. Implements a contract-first protocol where upstream agents (database → backend → frontend) publish interface contracts before downstream agents build. The lead agent verifies contracts and runs end-to-end validation.

## Installation

### Commands

Copy the `.md` files to your Claude Code commands directory:

```bash
# User-level (available in all projects)
cp research.md plan.md implement.md ~/.claude/commands/

# Or project-level (available only in that project)
cp research.md plan.md implement.md /path/to/project/.claude/commands/
```

### Skills

Copy the skill directory:

```bash
cp -r skills/build-with-agent-team ~/.claude/skills/
```

## Usage

```bash
# Research a feature area
/research the authentication flow

# Create an implementation plan
/phased-plan PROJ-123
/phased-plan docs/research/2025-03-01-auth-flow.md

# Implement an approved plan
/implement docs/phased-plans/2025-03-01-auth-flow.md
/implement docs/phased-plans/2025-03-01-auth-flow.md phase 3  # Resume from phase 3

# Build with an agent team
/build-with-agent-team docs/phased-plans/2025-03-01-auth-flow.md 3
```

## Customization

These commands are project-agnostic. They reference your project's `CLAUDE.md` for architecture rules, coding conventions, and tech stack details. To get the most out of them:

1. Ensure your project has a `CLAUDE.md` with architecture rules, common mistakes, and code style guidelines
2. Commands will write docs to `docs/research/` and `docs/phased-plans/` — create these directories in your project
3. The `/phased-plan` template includes a "Project-Specific Checklists" section — customize it per project

## How They Work Together

```
/research → produces docs/research/YYYY-MM-DD-topic.md
    ↓
/phased-plan → reads research doc, produces docs/phased-plans/YYYY-MM-DD-feature.md
    ↓
/implement → reads plan, executes phase-by-phase with verification gates
    ↓ (or for complex multi-agent builds)
/build-with-agent-team → reads plan, spawns coordinated agent team
```

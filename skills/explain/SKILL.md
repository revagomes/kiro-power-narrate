---
name: explain
description: >-
  Explain the full story of a git feature branch — the why, what, and how — in
  text. Reconstructs the branch narrative (problem, root cause, implementation,
  verification) from git history, the diff, and any available tickets, specs,
  and docs. Use when asked to "explain this branch", or to understand a branch
  before review or handoff. Takes an optional branch name; defaults to the
  current branch.
keywords:
  - explain
  - branch
  - story
  - review
  - handoff
  - summary
---

## Task

Explain, in text, the complete story of a git feature branch — the **why**,
**what**, and **how** — so a reviewer or new team member understands it without
doing their own archaeology.

**Target branch:** `$ARGUMENTS` (optional; defaults to the current branch)

### Steps

1. **Resolve the branch.** If `$ARGUMENTS` is empty, use the current branch:
   `git branch --show-current`. Otherwise use the provided name (trim
   whitespace). If the given branch does not exist locally, say so and stop.

2. **Run the `explain-branch` skill.** Activate the `explain-branch` skill from
   this power (`skills/explain-branch/SKILL.md`) and follow its procedure
   exactly — it detects the merge base, gathers git history and the full diff,
   fetches ticket data via whatever issue-tracker MCP is available (if any), and
   checks for matching specs, ADRs, and engineering notes.

3. **Produce the narrative** in the structure that skill defines
   (🎯 Why → 🔍 Investigation / Root Cause → 🛠️ What Changed → 🧪 Testing →
   🛡️ Review → ⚠️ Risks / Follow-ups). Keep it accurate and evidence-based:
   cite ticket IDs, file paths, and commit SHAs; do not invent rationale that
   the evidence does not support. If something cannot be determined, say so.

### Notes

- This is the **text-only** variant. For a spoken explanation, use the
  `explain-audio` skill.
- Read-only: do not modify the branch, tickets, or any files.

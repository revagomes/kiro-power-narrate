---
name: explain-branch
description: >-
  Reconstruct the full narrative of a git feature branch — the why, what, and
  how — from git history, the diff, and any available tickets, specs, and
  architecture notes. Produces a structured story a reviewer, new team member,
  or future developer can read without doing their own archaeology. Read-only.
keywords:
  - explain
  - branch
  - story
  - review
  - handoff
  - git history
  - narrative
---

# Skill: Explain Branch

Reconstructs the full narrative of a feature branch — the why, what, and how —
from git history, tickets, diffs, and project documentation. Produces a
structured story that a reviewer, new team member, or future developer can read
to fully understand the branch without archaeology.

This is the underlying procedure used by the `explain` (text) and `explain-audio`
(spoken) skills. It can also be invoked directly.

## When to Use

- User says "explain this branch", "tell me the story of this branch",
  "summarize what happened on this branch"
- User provides a branch name and wants to understand it
- Before a merge/pull request review, to onboard the reviewer
- When handing off a branch to another developer
- When writing release notes from feature branches

## Procedure

### Step 1: Identify the Branch

If the user provides a branch name, use it. Otherwise use the current branch:

```bash
BRANCH="$(git branch --show-current)"
```

If the named branch does not exist locally, say so and stop.

### Step 2: Determine the Base

Find the merge base so you know which commits belong to this branch. Detect the
integration branch rather than assuming one — try the branch's upstream first,
then common names:

```bash
# 1. Prefer the configured upstream of the current branch.
UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"

# 2. Fall back to common integration branches, local or remote.
CANDIDATES="${UPSTREAM:-} origin/main origin/master main master origin/develop develop"

BASE=""
for ref in $CANDIDATES; do
  [ -z "$ref" ] && continue
  if git rev-parse --verify --quiet "$ref" >/dev/null; then
    BASE="$(git merge-base "$ref" HEAD 2>/dev/null || true)"
    [ -n "$BASE" ] && { echo "Base: $ref ($BASE)"; break; }
  fi
done
```

If no base can be determined (e.g. an orphan branch), fall back to the root
commit or explain only the most recent commits, and note the limitation.

### Step 3: Gather Raw Data

Collect all evidence; run independent commands in parallel where possible.

**Git history:**
```bash
git log --oneline --stat "$BASE"..HEAD   # commits with per-file stats
git diff "$BASE"..HEAD                    # the complete diff
```

**Ticket (optional — only if a tracker is wired up):**
- Extract a ticket ID from the branch name or commit messages. Use a project-
  appropriate pattern; a reasonable default is an uppercase project key plus a
  number, e.g. `[A-Z][A-Z0-9]+-\d+` (matches `PROJ-123`, `ABC-45`), or a bare
  `#\d+` for GitHub/GitLab issues.
- If an issue-tracker MCP is available (Jira, GitLab, GitHub, Linear, etc.),
  fetch the ticket's description, status, priority, reporter, and comments, plus
  any linked/blocking tickets for context.
- If no ticket ID is found or no tracker MCP is available, skip this entirely and
  reconstruct intent from commit messages and the diff. Do **not** invent a
  ticket or rationale.

**Project artifacts (optional, best-effort):**
- Look for a spec or design doc matching the ticket ID or branch name under a
  specs/docs directory (e.g. `docs/`, `specs/`, `.specs/`, or a project-specific
  location). Common patterns: `*<TICKET>*.md`, `*<branch-slug>*.md`.
- Look for an architecture decision record (ADR) referencing the ticket.
- Look for any engineering notes / changelog entries captured during the work.

Only use artifacts that actually exist. Absence is normal — never fabricate.

### Step 4: Synthesize the Narrative

Produce the output in this structure (omit sections that have no evidence):

---

## 🎯 Why — The Problem

- What was the bug / feature / improvement?
- Who reported it and when? (if known)
- What was the user-visible impact?
- What was the urgency / priority? (if known)

Source: ticket description + reporter + priority, or commit messages.

## 🔍 Investigation — Root Cause

- What was investigated?
- What was the root cause? (technical detail — file paths, function names, the
  mechanism)
- Were there red herrings or wrong initial hypotheses?
- What data confirmed the diagnosis?

Source: ticket comments, spec files, commit messages mentioning "investigate" /
"fix".

## 🛠️ What Changed — The Implementation

For each logical change (group related commits):

- **What**: which files changed and what they do
- **Why this approach**: alternatives considered, why this one was chosen
- **Key design decision**: any non-obvious choice that needs explanation

Source: `git log`, `git diff`, ADRs. Present commits in logical (not necessarily
chronological) order; group test + implementation commits together.

## 🧪 Testing — Verification

- What tests were written? (unit, integration, end-to-end)
- What do they verify? (specific scenarios, not just "tests pass")
- What quality gates ran? (linters, static analysis, type checks, reviews)

Source: test file contents, CI config, commit messages.

## 🛡️ Review — Findings

If code reviews are evidenced in the history:
- How many passes?
- What significant findings were caught and fixed?
- What minor findings were acknowledged vs fixed?

Source: commit messages, MR/PR description.

## ⚠️ Risks & Follow-ups

- What trade-offs were accepted?
- What follow-up tickets/issues were created?
- What could break if assumptions change?
- Any documentation / config updates needed?

Source: linked tickets, notes, config/docs changes in the diff.

---

### Step 5: Format

- Use prose, not bullet soup — tell a story
- Include file paths and function names for technical context
- Quote the most important code changes inline (short snippets, not full files)
- Link to tickets and MR/PR URLs where relevant
- Keep it under ~2000 words unless the branch is exceptionally complex
- Base every claim on evidence; if something can't be determined, say so

## Example Invocation

User: "Explain the feature/login-rework branch"

1. Run `git log --oneline <base>..feature/login-rework`
2. Try to extract a ticket ID from commits/branch (e.g. `PROJ-321`)
3. If a tracker MCP is present, fetch that ticket; otherwise skip
4. Read the diff, look for a matching spec/ADR/notes
5. Produce the narrative

## Edge Cases

- **No ticket / no tracker MCP**: skip the ticket section, reconstruct from
  commits only
- **Already merged**: use `git log <merge-base>..<branch-tip>` from the ref
- **Multiple ticket IDs**: cover each as a sub-section
- **Very large branch (50+ commits)**: group by ticket ID or by phase
  (investigation, implementation, review fixes, documentation)
- **Branch based on non-default integration branch**: detect the real base from
  the tracking branch (Step 2)

## What This Skill Does NOT Do

- Does not modify any files, commits, branches, or tickets
- Does not judge code quality (that is a reviewer's job)
- Does not propose changes — it only explains what was done and why

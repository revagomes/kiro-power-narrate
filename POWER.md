---
name: "narrate"
displayName: "Narrate"
description: "Explain a git feature branch's full story — the why, what, and how — reconstructed from git history, tickets, diffs, specs, and docs, delivered as text or spoken aloud via a local, offline Piper text-to-speech engine. Use to understand a branch before review or handoff, or any time you want audio feedback from the agent."
keywords: ["explain", "branch", "narrate", "tts", "text-to-speech", "speak", "piper", "audio", "review", "handoff", "git", "story", "voice", "offline"]
author: "Renato Vasconcellos Gomes"
---

# Narrate

## Overview

This power bundles three skills around one idea: turning dense engineering
context into a clear narrative — in text, or spoken aloud through a fully
offline text-to-speech engine (Piper).

**Key capabilities:**

- **Explain a branch** — Reconstruct the complete story of a feature branch
  (why it exists, what was investigated, what changed, how, and how it was
  verified) from git history, the diff, and any available tickets, specs, and
  architecture notes. Text output.
- **Explain a branch, out loud** — The same reconstruction, adapted for speech
  and read aloud at a brisk pace, with a short written recap.
- **Speak** — General-purpose local text-to-speech. Read any text, document, or
  progress update aloud. Runs entirely offline; no cloud API, no account, no
  data leaves the machine.

The TTS integration is a self-contained shell CLI (`bin/speak`) that wraps the
`piper` binary — **not** an MCP server. This keeps the power dependency-light
and portable: install one script, download a voice model, done.

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| **`piper`** | The Piper TTS engine. Install with `uv tool install piper-tts` (or `pipx install piper-tts`). |
| **`aplay`** | Audio playback (ALSA, pre-installed on most Linux systems). On macOS the installer falls back to `afplay`. |
| **At least one voice model** | A `.onnx` + `.onnx.json` pair under `~/.local/share/piper-voices/`. The installer can fetch a default English voice for you. |
| **git** | Required for the explain / explain-audio skills. |
| **A ticket-tracker MCP** | *Optional.* If a Jira/GitLab/GitHub issues MCP is present, the explain skills enrich the narrative with ticket data. Fully optional — the skills work from git history alone. |

Run the installer once after enabling the power:

```bash
bash install.sh
```

It copies `bin/speak` to `~/.local/bin/speak`, checks for `piper`/`aplay`, and
offers to download a default English voice model. Nothing in this power requires
secrets or environment variables.

## Skills

| Skill | When to use |
|-------|-------------|
| `speak` (`skills/speak/SKILL.md`) | Read text aloud; announce progress/milestones; narrate a doc or summary for hands-free review; any audio feedback. |
| `explain` (`skills/explain/SKILL.md`) | Reconstruct and explain a feature branch in text — before review, during handoff, or to understand a branch you did not write. |
| `explain-audio` (`skills/explain-audio/SKILL.md`) | The same branch explanation delivered as spoken audio plus a short text recap. |
| `explain-branch` (`skills/explain-branch/SKILL.md`) | The underlying procedure the two explain skills call. Not usually invoked directly. |

## Activation Keywords

This power activates when you mention:
- explain this branch, tell the story of a branch, summarize a branch
- read this aloud, say this, speak, narrate, tell me aloud
- text-to-speech, TTS, Piper, voice, audio feedback

## Quick Usage Examples

### Explain the current branch (text)

User: "Explain this branch."
→ Run the `explain` skill against the current branch; produce the
  Why → Investigation → What → How → Verification narrative.

### Explain a named branch, out loud

User: "Narrate the feature/login-rework branch."
→ Run `explain-audio`: build the narrative, adapt it for speech, read it aloud
  with `bin/speak`, then print a 3–6 line recap.

### Read a document aloud

User: "Read me the design doc summary."
→ Use the `speak` skill: `printf '%s' "<summary>" | speak -s 0.4`

## Design Notes

- **Offline by default.** Piper runs locally; no text is sent anywhere.
- **No MCP.** TTS is a shell CLI, deliberately. It is trivial to audit and port.
- **Ticket tracker is optional and generic.** The explain skills detect a ticket
  ID with a configurable pattern and use whatever issue-tracker MCP is available;
  with none, they fall back to git history and commit messages.

---
name: explain-audio
description: >-
  Explain a git feature branch's why, what, and how OUT LOUD. Reconstructs the
  branch narrative then reads a speech-adapted summary aloud via the local
  `speak` (Piper TTS) CLI at a brisk pace, followed by a short text recap. Use
  when asked to "explain this branch aloud" or "narrate this branch". Takes an
  optional branch name; defaults to the current branch.
keywords:
  - explain
  - branch
  - audio
  - narrate
  - speak
  - tts
  - out loud
---

## Task

Explain a git feature branch (**why / what / how**) and deliver it as **spoken
audio** at a brisk pace, plus a short text recap.

**Target branch:** `$ARGUMENTS` (optional; defaults to the current branch)

### Steps

1. **Build the narrative** exactly as the `explain` skill does: resolve the
   branch (`$ARGUMENTS` or current via `git branch --show-current`) and run the
   `explain-branch` skill to gather git / ticket / specs / notes evidence and
   synthesise the Why → Investigation → What → How story. Do this work silently
   (don't dump the full raw narrative first, unless the user also wants the
   text).

2. **Adapt the narrative for speech** following the `speak` skill's guidance:
   - Spell out abbreviations on first use (e.g. "ADR, an Architecture Decision
     Record").
   - **Do not read** code snippets, diffs, file paths, or SHAs — describe what
     they do in plain language instead.
   - Convert bullet lists to spoken "First… Next… Finally…".
   - Keep it to a tight spoken summary (aim ~45–90 seconds), not the full text.

3. **Speak it** using the `speak` CLI at a brisk pace.
   NOTE: in `speak`, the `-s` value is a time multiplier where **lower = faster**
   (0.6 is the default). For a faster, roughly 2× delivery, use `-s 0.4`.
   Pipe the adapted text via stdin so long content isn't passed as an argument:

   ```bash
   printf '%s' "<speech-adapted summary>" | speak -v us -s 0.4
   ```

   Use `-v br` instead if the user asks for Brazilian Portuguese (requires that
   voice model to be installed).

4. **Print a short text recap** (3–6 lines) after speaking, so there is a
   written trace of what was narrated.

### Notes

- Requires the `speak` CLI (Piper TTS) and working audio output. If `speak` is
  not available, fall back to the text-only `explain` output and say that audio
  was unavailable.
- Read-only: do not modify the branch, tickets, or any files.

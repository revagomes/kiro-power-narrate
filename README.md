# Narrate — a Kiro Power

Explain a git feature branch's full story — the **why**, **what**, and **how** —
reconstructed from git history, the diff, and any available tickets, specs, and
docs, delivered as **text** or **spoken aloud** through a fully **offline**
Piper text-to-speech engine.

Four skills, one idea: turn dense engineering context into a clear narrative you
can read or hear.

| Skill | What it does |
|-------|--------------|
| **explain** | Reconstructs a branch's story as text (why → investigation → what → testing → risks). |
| **explain-audio** | The same story, adapted for speech and read aloud at a brisk pace, plus a short text recap. |
| **speak** | General-purpose local text-to-speech — read any text, doc, or progress update aloud. |
| **explain-branch** | The shared procedure the two explain skills call. Not usually invoked directly. |

The text-to-speech integration is a **self-contained shell CLI** (`bin/speak`)
that wraps the [`piper`](https://github.com/rhasspy/piper) binary — **not** an
MCP server. Everything runs locally; no cloud API, no account, no data leaves
your machine.

## Install

1. **Enable the power** in Kiro (drop/clone this directory where your Kiro
   powers live, then activate `narrate`).

2. **Run the installer** once:

   ```bash
   bash install.sh
   ```

   It will:
   - copy `bin/speak` to `~/.local/bin/speak` (override with `BIN_DIR=...`),
   - check that `piper` and an audio player (`aplay` on Linux, `afplay` on macOS)
     are available,
   - offer to download a default English voice model if you have none.

3. **Install Piper** if the installer reported it missing:

   ```bash
   uv tool install piper-tts      # or: pipx install piper-tts
   ```

4. **Verify:**

   ```bash
   speak "Narration is ready."
   ```

### Non-interactive install

```bash
NARRATE_AUTO_VOICE=1 bash install.sh   # auto-download the default voice, no prompt
```

## Usage

### Explain the current branch (text)

> "Explain this branch."

### Narrate a named branch (audio)

> "Narrate the `feature/login-rework` branch."

Builds the narrative, reads a ~45–90 s speech-adapted summary aloud, then prints
a short recap.

### Read arbitrary text aloud

```bash
printf '%s' "Your text here" | speak        # default English, fast
speak -v br -s 0.8 "Olá, tudo bem?"         # Brazilian Portuguese, natural pace
```

Speed is a time multiplier where **lower = faster**: `1.0` slow, `0.8` natural,
`0.6` fast (default), `0.4` very fast.

## Voices

Models live in `~/.local/share/piper-voices/` (override with `PIPER_VOICES_DIR`).
Built-in aliases: `us`/`en` → `en_US-amy-medium`, `br`/`pt` → `pt_BR-faber-medium`.
Download more from the [Piper voices repository](https://huggingface.co/rhasspy/piper-voices)
and reference them by filename (without the `.onnx` extension), or add an alias
in `get_model()` inside `bin/speak`.

## Issue-tracker enrichment (optional)

The explain skills work from git history alone. If an issue-tracker MCP
(Jira, GitLab, GitHub, Linear, …) is available in your Kiro environment, they
will additionally pull the ticket's description, status, and comments to enrich
the narrative. A ticket ID is detected from the branch name or commit messages
using a generic pattern (`PROJ-123` or `#123`). No tracker is required.

## Requirements

- **Linux or macOS** with a shell
- **`piper`** (`uv tool install piper-tts`)
- **`aplay`** (Linux/ALSA) or **`afplay`** (macOS, built in)
- **`git`** (for the explain skills)
- At least one Piper voice model

## Privacy

Text-to-speech is fully offline. The `speak` CLI only runs `piper` locally and
plays the resulting audio. The explain skills are **read-only** — they never
modify branches, tickets, or files.

## License

GNU General Public License, version 2 **or later** (`GPL-2.0-or-later`).
See [`COPYRIGHT`](./COPYRIGHT) for the authorship and "or later" grant, and
[`LICENSE`](./LICENSE) for the full GPL version 2 text.

Copyright © Renato Vasconcellos Gomes.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 2 of the License, or (at your option) any later
version.

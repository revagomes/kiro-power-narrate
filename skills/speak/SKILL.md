---
name: speak
description: >-
  Provide text-to-speech audio feedback using a local, offline Piper TTS CLI
  (installed as `speak`). Use when the user asks to read something aloud,
  announce progress audibly, narrate a document or summary, or wants audio
  rather than text. Also useful proactively when finishing a long task or
  delivering a summary the user might prefer to hear.
keywords:
  - speak
  - tts
  - text-to-speech
  - piper
  - audio
  - voice
  - read aloud
  - narrate
---

# Speak — Local Text-to-Speech

Converts text to natural-sounding speech using Piper TTS, running fully offline
on the local machine. No cloud API, no account, no data leaves the machine.

## When to Use

- User asks you to "read this", "say this", "speak", or "tell me aloud"
- Announcing subagent task completion or progress milestones
- Reading specs, design docs, or summaries for hands-free review
- Providing audio feedback on errors, blockers, or decisions needed
- Any time the user has indicated they want audio responses

## When NOT to Use

- Normal text-based conversation (unless the user asked for audio)
- Very short text (a single word or "ok") — just type it
- When the user explicitly asks for silence or text-only mode

## Tool

The CLI is installed by this power's `install.sh` as:

```
~/.local/bin/speak
```

If `speak` is not on PATH, invoke it by full path, or run `bash install.sh`
from the power directory first.

## Usage

### Basic (English, fast pace)

```bash
speak "Your text here"
```

### From stdin (preferred for longer text)

```bash
printf '%s' "Longer text or piped content" | speak
```

Piping avoids shell-argument length limits and quoting problems — always pipe
anything longer than a sentence.

### Voice selection

```bash
speak -v us "Hello world"       # English US (default)
speak -v br "Olá, tudo bem?"    # Brazilian Portuguese (if that model is installed)
```

### Speed control (lower = faster)

```bash
speak -s 1.0 "Slow, original Piper pace"
speak -s 0.8 "Natural pace"
speak -s 0.6 "Fast (default)"
speak -s 0.4 "Very fast"
```

### Combined

```bash
speak -v br -s 0.8 "Português mais devagar"
```

## Voice Aliases

| Alias | Language | Model |
|-------|----------|-------|
| `us` or `en` | English (US) | `en_US-amy-medium` |
| `br` or `pt` | Portuguese (BR) | `pt_BR-faber-medium` |

You can also pass any model filename (without the `.onnx` extension) that exists
in `~/.local/share/piper-voices/` (override the directory with
`PIPER_VOICES_DIR`).

## Adding New Voices

Download from the Piper voices repository on HuggingFace:

```bash
cd ~/.local/share/piper-voices
BASE="https://huggingface.co/rhasspy/piper-voices/resolve/main"
curl -fsSL "$BASE/<lang>/<locale>/<name>/<quality>/<locale>-<name>-<quality>.onnx"      -o "<locale>-<name>-<quality>.onnx"
curl -fsSL "$BASE/<lang>/<locale>/<name>/<quality>/<locale>-<name>-<quality>.onnx.json" -o "<locale>-<name>-<quality>.onnx.json"
```

Then reference it by its filename, or add an alias in the `get_model()` function
in `~/.local/bin/speak`. Browse voices: https://huggingface.co/rhasspy/piper-voices

## Best Practices for AI Agents

### Reading specs / documents aloud
- Break long documents into logical sections (overview, goals, architecture)
- Paraphrase code blocks and file trees rather than reading them literally
- Use natural phrasing: "First", "Next", "Finally" for lists

### Progress announcements
- Keep them concise: "Task three complete. Service registered, all tests passing."
- Announce meaningful milestones only, not every small step
- Use for: task start, task complete, errors/blockers, decisions needed

### Adapting technical content for speech
- Spell out abbreviations on first use: "TDD, that is, Test Driven Development"
- Replace file paths with natural descriptions where possible
- Convert bullet points to numbered spoken items
- Skip code snippets — describe what the code does instead

## Dependencies

- `piper` (install via `uv tool install piper-tts`)
- An audio player: `aplay` (Linux/ALSA) or `afplay` (macOS)
- At least one voice model in `~/.local/share/piper-voices/`

## Troubleshooting

- **"piper not found"**: install it with `uv tool install piper-tts`
- **"voice model not found"**: download a model (see above) or run `install.sh`
- **No sound**: check `aplay -l` for available audio devices
- **Too slow/fast**: adjust the `-s` flag (lower = faster)

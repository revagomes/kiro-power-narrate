#!/bin/bash
# install.sh - Install the "narrate" power's speak CLI and check prerequisites.
#
# - Copies bin/speak to ~/.local/bin/speak (override with BIN_DIR=...)
# - Checks for piper and an audio player (aplay/afplay)
# - Offers to download a default English voice model if none is present
#
# Safe to re-run; it overwrites only ~/.local/bin/speak.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
VOICES_DIR="${PIPER_VOICES_DIR:-$HOME/.local/share/piper-voices}"
DEFAULT_VOICE="en_US-amy-medium"
HF_BASE="https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/amy/medium"

info() { printf '  %s\n' "$*"; }
warn() { printf '  ! %s\n' "$*" >&2; }
ok()   { printf '  ✓ %s\n' "$*"; }

echo "Installing the 'narrate' power..."

# 1. Install the CLI.
mkdir -p "$BIN_DIR"
install -m 0755 "$SCRIPT_DIR/bin/speak" "$BIN_DIR/speak"
ok "Installed speak -> $BIN_DIR/speak"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) warn "$BIN_DIR is not on your PATH. Add it to your shell profile:"
       info "export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

# 2. Check piper.
if command -v piper >/dev/null 2>&1; then
    ok "piper found: $(command -v piper)"
else
    warn "piper not found. Install it with one of:"
    info "uv tool install piper-tts"
    info "pipx install piper-tts"
fi

# 3. Check an audio player.
if command -v aplay >/dev/null 2>&1; then
    ok "audio player found: aplay"
elif command -v afplay >/dev/null 2>&1; then
    ok "audio player found: afplay (macOS)"
else
    warn "No audio player found. Install ALSA utils (provides 'aplay') on Linux."
fi

# 4. Voice model.
mkdir -p "$VOICES_DIR"
if ls "$VOICES_DIR"/*.onnx >/dev/null 2>&1; then
    ok "Voice model(s) already present in $VOICES_DIR"
else
    warn "No voice models found in $VOICES_DIR"
    if [ "${NARRATE_AUTO_VOICE:-}" = "1" ]; then
        REPLY="y"
    else
        printf '  Download the default English voice (%s, ~60 MB)? [y/N] ' "$DEFAULT_VOICE"
        read -r REPLY || REPLY="n"
    fi
    if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
        if ! command -v curl >/dev/null 2>&1; then
            warn "curl not found; cannot auto-download. Fetch manually from:"
            info "https://huggingface.co/rhasspy/piper-voices"
        else
            info "Downloading $DEFAULT_VOICE..."
            curl -fsSL "$HF_BASE/$DEFAULT_VOICE.onnx"      -o "$VOICES_DIR/$DEFAULT_VOICE.onnx"
            curl -fsSL "$HF_BASE/$DEFAULT_VOICE.onnx.json" -o "$VOICES_DIR/$DEFAULT_VOICE.onnx.json"
            ok "Downloaded $DEFAULT_VOICE to $VOICES_DIR"
        fi
    else
        info "Skipped. Download a voice later from https://huggingface.co/rhasspy/piper-voices"
    fi
fi

echo "Done. Test with:  speak \"Narration is ready.\""

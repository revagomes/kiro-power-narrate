#!/bin/bash
# install.sh - Install the "narrate" power's speak CLI and check prerequisites.
#
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 Renato Vasconcellos Gomes
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 2 of the License, or (at your option) any later
# version. See the LICENSE file for the full text.
#
# - Copies bin/speak to ~/.local/bin/speak (override with BIN_DIR=...)
# - Checks for piper and an audio player (aplay/afplay)
# - Optionally downloads a voice model, pinned to an immutable release tag and
#   verified against a known SHA256 before it is placed in the voices directory
#
# Environment:
#   BIN_DIR            install target for the speak CLI (default ~/.local/bin)
#   PIPER_VOICES_DIR   voices directory (default ~/.local/share/piper-voices)
#   NARRATE_VOICE      which voice to offer: en (default) or pt
#   NARRATE_AUTO_VOICE =1 to download the chosen voice without prompting
#
# Safe to re-run; it overwrites only ~/.local/bin/speak.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
VOICES_DIR="${PIPER_VOICES_DIR:-$HOME/.local/share/piper-voices}"

# Voice models are pinned to an immutable upstream release tag (not a moving
# branch) and verified against the SHA256 published in the tag's Git-LFS
# pointer. Update the tag and both hashes together if you bump the version.
PIPER_VOICES_TAG="v1.0.0"
HF_BASE="https://huggingface.co/rhasspy/piper-voices/resolve/${PIPER_VOICES_TAG}"

NARRATE_VOICE="${NARRATE_VOICE:-en}"

info() { printf '  %s\n' "$*"; }
warn() { printf '  ! %s\n' "$*" >&2; }
ok()   { printf '  \xe2\x9c\x93 %s\n' "$*"; }

# voice-key -> "model-name relative-path sha256"
voice_spec() {
    case "$1" in
        en|us) echo "en_US-amy-medium en/en_US/amy/medium b3a6e47b57b8c7fbe6a0ce2518161a50f59a9cdd8a50835c02cb02bdd6206c18" ;;
        pt|br) echo "pt_BR-faber-medium pt/pt_BR/faber/medium 858555e3a064209c57088fe6bd70c4c3dc54d03eaa00c45d5ecaf43a33f95aa7" ;;
        *)     return 1 ;;
    esac
}

# sha256 of a file, portable across Linux (sha256sum) and macOS (shasum -a 256).
sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        return 2
    fi
}

download_voice() {
    local key="$1" spec name rel want
    if ! spec="$(voice_spec "$key")"; then
        warn "Unknown voice '$key' (known: en, pt). Skipping download."
        return 0
    fi
    # shellcheck disable=SC2086
    set -- $spec
    name="$1"; rel="$2"; want="$3"

    if [ -f "$VOICES_DIR/$name.onnx" ] && [ -f "$VOICES_DIR/$name.onnx.json" ]; then
        ok "Voice '$name' already installed."
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1; then
        warn "curl not found; cannot auto-download. Fetch '$name' manually from:"
        info "$HF_BASE/$rel/$name.onnx"
        return 0
    fi
    if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
        warn "No sha256 tool (sha256sum/shasum); refusing to install an unverified model."
        return 0
    fi

    # Download atomically into a temp dir; only move into place after both files
    # are present and the model's SHA256 matches the pinned expectation.
    local tmp
    tmp="$(mktemp -d "${TMPDIR:-/tmp}/narrate-voice-XXXXXX")"
    # shellcheck disable=SC2064
    trap "rm -rf '$tmp'" RETURN

    info "Downloading voice '$name' (pinned $PIPER_VOICES_TAG, ~60 MB)..."
    if ! curl -fsSL --proto '=https' --tlsv1.2 "$HF_BASE/$rel/$name.onnx"      -o "$tmp/$name.onnx" ||
       ! curl -fsSL --proto '=https' --tlsv1.2 "$HF_BASE/$rel/$name.onnx.json" -o "$tmp/$name.onnx.json"; then
        warn "Download failed; nothing was installed."
        return 0
    fi

    local got
    got="$(sha256_of "$tmp/$name.onnx")" || { warn "Could not hash the download."; return 0; }
    if [ "$got" != "$want" ]; then
        warn "SHA256 mismatch for $name.onnx — refusing to install."
        info "expected: $want"
        info "got:      $got"
        return 0
    fi

    mkdir -p "$VOICES_DIR"
    mv -f "$tmp/$name.onnx" "$tmp/$name.onnx.json" "$VOICES_DIR/"
    ok "Installed and verified voice '$name' in $VOICES_DIR"
}

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
# Does the voices dir contain at least one model? (glob, not ls — SC2012-safe)
have_voice=0
for _f in "$VOICES_DIR"/*.onnx; do
    [ -e "$_f" ] && { have_voice=1; break; }
done
if [ "$have_voice" -eq 1 ]; then
    ok "Voice model(s) already present in $VOICES_DIR"
else
    warn "No voice models found in $VOICES_DIR"
    if [ "${NARRATE_AUTO_VOICE:-}" = "1" ]; then
        REPLY="y"
    else
        printf '  Download the default voice (%s, ~60 MB)? [y/N] ' "$NARRATE_VOICE"
        read -r REPLY || REPLY="n"
    fi
    case "$REPLY" in
        y|Y) download_voice "$NARRATE_VOICE" ;;
        *)   info "Skipped. Re-run with NARRATE_AUTO_VOICE=1 (and optional NARRATE_VOICE=pt)." ;;
    esac
fi

echo "Done. Test with:  speak \"Narration is ready.\""

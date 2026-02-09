#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"

# --- Pre-flight checks ---
if ! command -v afplay &>/dev/null; then
  echo "Error: afplay not found. This project requires macOS." >&2
  exit 1
fi

# --- Copy sound files ---
mkdir -p "$HOOKS_DIR"
cp "$SCRIPT_DIR"/sounds/*.wav "$HOOKS_DIR/"
echo "Copied sound files to $HOOKS_DIR"

# --- Merge hooks into settings.json ---
mkdir -p "$HOME/.claude"

python3 << 'PYEOF'
import json, sys, os

settings_path = os.path.expanduser("~/.claude/settings.json")

# Load existing settings or start fresh
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)
else:
    settings = {}

# Bail out if hooks already exist
if "hooks" in settings and settings["hooks"]:
    print("Warning: hooks already exist in settings.json — skipping merge.")
    print("Remove existing hooks first or edit manually.")
    sys.exit(0)

d = "~/.claude/hooks"

settings["hooks"] = {
    "SessionStart": [{
        "hooks": [{
            "type": "command",
            "command": "afplay " + d + "/PeonReadyToWork.wav &"
        }]
    }],
    "UserPromptSubmit": [{
        "hooks": [{
            "type": "command",
            "command": "bash -c 'sounds=(PeonYes4.wav PeonWorkWork.wav); afplay " + d + "/${sounds[$((RANDOM % ${#sounds[@]}))]}' &"
        }]
    }],
    "Notification": [{
        "hooks": [{
            "type": "command",
            "command": "afplay " + d + "/PeonSomethingNeedDoing.wav &"
        }]
    }],
    "Stop": [{
        "hooks": [{
            "type": "command",
            "command": "afplay " + d + "/PeonJobsDone.wav &"
        }]
    }]
}

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("Hooks merged into " + settings_path)
PYEOF

echo ""
echo "=== Claude Sounds installed! ==="
echo ""
echo "  SessionStart        -> Ready to work     (PeonReadyToWork.wav)"
echo "  UserPromptSubmit    -> Okeydokey / Work!  (PeonYes4.wav / PeonWorkWork.wav)"
echo "  Notification        -> Something need doing? (PeonSomethingNeedDoing.wav)"
echo "  Stop                -> Job's done!        (PeonJobsDone.wav)"
echo ""
echo "Start a new Claude Code session to hear it!"

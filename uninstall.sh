#!/usr/bin/env bash
set -euo pipefail

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"

SOUND_FILES=(
  PeonReadyToWork.wav
  PeonYes4.wav
  PeonWorkWork.wav
  PeonSomethingNeedDoing.wav
  PeonJobsDone.wav
)

# --- Remove sound files ---
for f in "${SOUND_FILES[@]}"; do
  rm -f "$HOOKS_DIR/$f"
done
echo "Removed sound files from $HOOKS_DIR"

# --- Remove hooks from settings.json ---
if [ -f "$SETTINGS" ]; then
  python3 -c "
import json, os

settings_path = os.path.expanduser('$SETTINGS')
with open(settings_path) as f:
    settings = json.load(f)

if 'hooks' in settings:
    del settings['hooks']

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

print('Removed hooks from ' + settings_path)
"
fi

echo ""
echo "=== Claude Sounds uninstalled. ==="

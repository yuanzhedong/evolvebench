#!/bin/bash
# Prepare Modal build context: copy agents/ and configs/ into a task's environment/.
# Modal uses environment/ as build context (unlike docker-compose which uses repo root).
# Run before ENV=modal when agents/ or configs/ have changed.
#
# Usage:
#   ./scripts/prepare-modal-context.sh [task_path]
#
# Example:
#   ./scripts/prepare-modal-context.sh
#   ./scripts/prepare-modal-context.sh tasks/task-01-im-looking-for-backpack-under

set -e
cd "$(dirname "$0")/.."

TASK="${1:-tasks/task-01-im-looking-for-backpack-under}"
ENV_DIR="$TASK/environment"

if [ ! -d "agents" ] || [ ! -d "configs" ]; then
  echo "Error: agents/ and configs/ must exist in repo root"
  exit 1
fi

if [ ! -d "$ENV_DIR" ]; then
  echo "Error: $ENV_DIR not found"
  exit 1
fi

echo "Preparing Modal build context: copying agents + configs into $ENV_DIR..."
rm -rf "$ENV_DIR/agents" "$ENV_DIR/configs"
cp -r agents configs "$ENV_DIR/"
echo "Done."

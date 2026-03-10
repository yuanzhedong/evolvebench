#!/bin/bash
# Run any Harbor task with CocoaAgent.
#
# Usage:
#   ./run.sh [task_path] [output_dir]
#
# Examples:
#   ./run.sh                              # task-01, results/skill-phase1-test
#   ./run.sh tasks/task-01-im-looking-for-backpack-under
#   ./run.sh tasks/task-01-im-looking-for-backpack-under results/my-run
#
# Prerequisites:
#   Set API key: export OPENAI_API_KEY=sk-...
#   (No pre-built image — Harbor builds from task's environment/Dockerfile)
#
# Harbor passes OPENAI_API_KEY into the container when set.

set -e
cd "$(dirname "$0")"

if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY must be set (agent and LLM judge need it)"
    echo "  export OPENAI_API_KEY=sk-your-key"
    exit 1
fi

# Use skill-phase1 config for evolve_bench parity (same as modal run_skill_phase1.sh)
export COCOA_CONFIG="${COCOA_CONFIG:-/cocoa-agent/configs/skill-phase1.json}"
export COCOA_MAX_ITERATIONS="${COCOA_MAX_ITERATIONS:-10}"

TASK_PATH="${1:-tasks/task-01-im-looking-for-backpack-under}"
OUTPUT_DIR="${2:-results/skill-phase1-test}"
AGENT="${AGENT:-agents.cocoa_agent:CocoaHarborAgent}"
MODEL="${MODEL:-openai/gpt-4.1-mini}"

AK=""
[ -n "$OPENAI_API_KEY" ] && AK="--ak OPENAI_API_KEY=$OPENAI_API_KEY"
[ -n "$COCOA_MAX_ITERATIONS" ] && AK="$AK --ak COCOA_MAX_ITERATIONS=$COCOA_MAX_ITERATIONS"

echo "=== Harbor run: task=$TASK_PATH agent=$AGENT model=$MODEL ==="
harbor run \
  -p "$TASK_PATH" \
  --agent-import-path "$AGENT" \
  -m "$MODEL" \
  -o "$OUTPUT_DIR" \
  $AK

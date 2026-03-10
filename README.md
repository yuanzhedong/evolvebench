# harbor-evolve-bench

Run Harbor tasks using **CocoaAgent** — a generic agent that works with any task. Uses [official cocoabench/cocoa-agent](https://github.com/cocoabench/cocoa-agent).

## Prerequisites

- Docker
- [Harbor](https://harborframework.com/docs) (`uv tool install harbor` or `pip install harbor`)
- OpenAI API key (used by both the agent and the LLM-as-judge verifier; passed via `[verifier.env]` in task.toml)

## Quick Start

```bash
# 1. Set API key
export OPENAI_API_KEY=sk-your-key

# 2. Run a task (Harbor builds the image automatically; works locally and on cloud)
./run.sh                                    # task-01, default output
./run.sh tasks/task-01-im-looking-for-backpack-under results/my-run
```

No pre-built image required — the task's `environment/Dockerfile` is self-contained and builds everything from scratch.

## Structure

The **cocoa agent is generic** — it takes the task instruction from Harbor and runs it inside the container. No task-specific logic in the agent. Agent files live in `agents/`; the Docker build uses repo root as context and copies directly from there (no sync needed).

```
agents/cocoa_agent/            # Agent glue (single source of truth)
configs/                       # Agent configs (e.g. skill-phase1.json)
tasks/<task-name>/
├── instruction.md
├── task.toml
├── environment/
│   ├── Dockerfile            # Builds from repo root, COPYs agents/ and configs/
│   └── docker-compose.yaml   # Sets build context to repo root
├── solution/
└── tests/
```

## Adding a New Task

1. Create `tasks/<task-name>/` with `instruction.md`, `task.toml`, `solution/`, `tests/`
2. Copy `environment/` from an existing task (e.g. task-01) — it contains the Dockerfile and docker-compose.yaml
3. Update docker-compose.yaml paths if the task name differs (context and dockerfile paths)
4. Run with `-p tasks/<task-name>`

## Config (evolve_bench parity)

Uses `configs/skill-phase1.json` by default — same controller (gpt-4.1-mini) and sandbox (max_iterations: 50) as evolve_bench's `run_skill_phase1.sh`. Produces comparable results.

```bash
# Use default skill-phase1 config (same as evolve_bench)
./run.sh

# Use harbor-config instead
COCOA_CONFIG=/cocoa-agent/configs/harbor-config.json ./run.sh
```

## Run Options

```bash
./run.sh [task_path] [output_dir]
# task_path defaults to tasks/task-01-im-looking-for-backpack-under
# output_dir defaults to results/skill-phase1-test

# Override agent, model, or config
AGENT=agents.cocoa_agent:CocoaHarborAgent MODEL=openai/gpt-4.1-mini ./run.sh
COCOA_CONFIG=/cocoa-agent/configs/harbor-config.json ./run.sh
```

## Task

**task-01-im-looking-for-backpack-under**: Find 3–5 backpacks under $75 with features similar to https://www.amazon.com/dp/B09YRC9Y3G and summarize key features and prices.

## License

Apache 2.0

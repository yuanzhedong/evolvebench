# EvolveBench

Run **any agent** with [Harbor](https://harborframework.com/docs). Start with **CocoaAgent** — a generic agent that works with any task ([official cocoabench/cocoa-agent](https://github.com/cocoabench/cocoa-agent)).

## Prerequisites

- Docker
- [Harbor](https://harborframework.com/docs) (`uv tool install harbor` or `pip install harbor`)
- OpenAI API key (used by both the agent and the LLM-as-judge verifier)
- For Modal cloud runs: `MODAL_TOKEN_ID` and `MODAL_TOKEN_SECRET` from [modal.com/settings/tokens](https://modal.com/settings/tokens)

Optional: create a `.env` file from `.env.example` with your keys (`.env` is gitignored). `run.sh` loads it automatically.

## Quick Start

```bash
# 1. Set API key (or use .env — see Prerequisites)
export OPENAI_API_KEY=sk-your-key

# 2. Run a task with CocoaAgent (default)
./run.sh                                    # task-01, default output
./run.sh tasks/task-01-im-looking-for-backpack-under results/my-run
```

No pre-built image required — the task's `environment/Dockerfile` is self-contained and builds everything from scratch.

## Structure

Agents are pluggable. Each agent lives in `agents/` and implements Harbor's `BaseInstalledAgent`. **CocoaAgent** was integrated by following Harbor's [installed agents](https://harborframework.com/docs/agents#installed-agents) guide. It is generic — it takes the task instruction from Harbor and runs it inside the container. No task-specific logic in the agent. The Docker build uses repo root as context and copies directly from there (no sync needed).

```
evolvebench/
├── run.sh                    # Main entry: harbor run with CocoaAgent
├── agents/
│   └── cocoa_agent/          # CocoaAgent — default, works with any task
├── configs/
│   └── skill-phase1.json    # Shared agent configs
├── scripts/
│   └── prepare-modal-context.sh   # Copy agents+configs for Modal build
└── tasks/
    └── <task-name>/
        ├── instruction.md
        ├── task.toml
        ├── environment/
        │   ├── Dockerfile          # Builds from repo root, COPYs agents/ and configs/
        │   └── docker-compose.yaml # Sets build context to repo root (Docker only)
        ├── solution/
        │   └── solve.sh            # Oracle: produces result.json for verifier
        └── tests/
            ├── test.sh             # Harbor verifier: LLM-as-judge, writes reward
            └── test_task.py        # Rubric evaluation logic
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

# Run a different agent (default: CocoaAgent)
AGENT=agents.cocoa_agent:CocoaHarborAgent ./run.sh

# Run on Modal (cloud) instead of local Docker
ENV=modal ./run.sh

# Override model or CocoaAgent config
MODEL=openai/gpt-4.1-mini ./run.sh
COCOA_CONFIG=/cocoa-agent/configs/harbor-config.json ./run.sh
```

Supported `ENV` values: `docker` (default), `modal`, `e2b`, `daytona`, `runloop`, `gke`. To add more agents, see `agents/README.md`.

### Modal (cloud)

For `ENV=modal`, run `./scripts/prepare-modal-context.sh` first (or let `run.sh` call it automatically). This copies `agents/` and `configs/` into the task's `environment/` since Modal uses that as the build context. The first Modal run takes ~10–20 minutes to build the image (Playwright + Chromium). If the image build fails, run with `--debug` to see build logs.

## Task

**task-01-im-looking-for-backpack-under**: Find 3–5 backpacks under $75 with features similar to https://www.amazon.com/dp/B09YRC9Y3G and summarize key features and prices.

### Sample output (rubric scores)

```
=== Customized Rubric Score: 3.8/5 ===
  source_navigation: 3/5
  budget_compliance: 5/5
  recommendation_count: 5/5
  feature_comparison: 3/5
  actionability: 3/5

Customized reasoning: The agent claims to have accessed the original Amazon URL, but the provided steps show limited interaction, resulting in a vague understanding of the product's specific features, thus a score of 3 for source_navigation. All alternative products are priced under $75, earning a score of 5 for budget_compliance. The agent presented exactly 3 distinct product alternatives, scoring a 5 for recommendation_count. However, the feature comparison against the original product is basic, only generally mentioning shared features like compartments and water resistance without detail, resulting in a score of 3 for feature_comparison. Finally, the response is structured to some extent but lacks precise product identifiers or direct links, only justifying a score of 3 for actionability.

=== Generic Rubric Score: 2.6/5 ===
  task_completion: 3/5
  information_quality: 2/5
  response_quality: 2/5
  completeness: 3/5

Generic reasoning: The AI agent provided three backpack options under $75 with features that partially match the original. However, the response lacks a thorough comparison to the original backpack, and it did not fully research or verify all features of the original item. The information is somewhat vague and lacks proper citations or links to the product pages for verification. The structure is adequate but lacks detail and depth, making it less useful for making an informed decision.

Evaluation: passed=True  score=3.80
```

## License

Apache 2.0

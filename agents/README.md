# Agents

Each subdirectory contains the full setup for one agent type (glue + Harbor wrapper). All agent files live here; the Docker build uses repo root as context and COPYs directly from `agents/` (no sync step).

**`cocoa_agent/`** — cocoabench/cocoa-agent
  - `cocoa_harbor_agent.py` — Harbor `BaseInstalledAgent` (import: `agents.cocoa_agent:CocoaHarborAgent`)
  - `run_task.py` — Entry point run inside the container
  - `overlay.py` — skip_docker patch
  - `configs/`, `agents_overlay/`

  No install template — CocoaAgent is pre-installed in the Docker image; we override `setup()` to skip the install step.

## Adding a new agent

1. Create `agents/<agent_name>/` with:
   - `run_task.py` — CLI entry point (Harbor → agent)
   - `configs/`, overlays, etc.
   - `install_<agent>.sh.j2` — Install template (omit if agent is pre-installed in the image; override `setup()` instead)

2. Create `agents/<agent>_harbor_agent.py` — `BaseInstalledAgent` subclass

3. Tasks use the Dockerfile to build the environment; docker-compose sets build context to repo root.

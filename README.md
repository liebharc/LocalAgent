# AI Sandbox Agent

Inspired by https://mfyz.com/ai-coding-agent-sandbox-container/

## Purpose

This repository provides a containerized sandbox for running an AI coding agent:

- unobserved (headless, autonomous),
- with minimal network access (only AI provider + search provider),
- confined by firewall rules to limit damage,
- running inside a Docker container, which enforces limited filesystem access,
- validated by automated tests to ensure isolation before any autonomous execution.

The agent can generate code, reason, and interact with configured AI/search providers without accessing the host system or external networks.

## What It Does

- Builds an agent container with Node, Python, Rust toolchains and the `@charmland/crush` CLI.
- Runs inside Docker, inherently restricting filesystem access to only mounted volumes.
- Enforces strict firewall policies: blocks all external traffic except whitelisted internal services (`localai` and `searchmcp`).
- Runs automated tests to confirm firewall effectiveness and absence of external internet access.
- Drops root privileges early and runs the agent as a non‑root user.
- Starts the agent CLI for autonomous execution.

## Alternative: Hosted AI Providers via Langdock

For users who prefer using a hosted AI provider rather than a fully local setup, Langdock can be used in the EU to access **Claude Code**. In this scenario, a LocalAI container would be replaced with a proxy, routing only LLM traffic to Langdock while blocking all other internet access.

The project focuses on `crush` with LocalAI because LocalAI provides an OpenAI-compatible interface that `crush` can use directly. LocalAI does not support Anthropic/Claude-compatible endpoints.

## Architecture

Three services are orchestrated via Docker Compose:

1. **localai** — Local OpenAI‑compatible AI provider, serving models on port `8080`.
2. **searchmcp** — SSE‑based search service on port `8000`.
3. **agent** — Builds and runs the sandboxed agent environment:
   - Installs dependencies inside the container.
   - Applies iptables rules to isolate network.
   - Executes tests and then runs the `crush` CLI “YOLO” agent loop.

All services run on a dedicated Docker network with enforced isolation.

## Models

These models were evaluated on NVIDIA Geforce RTX 4060 Ti with 16 GB memory:

- 🔹 **deepseek-r1-distill-qwen-7b** – Worked somewhat, but performance and reliability were poor.
- ❌ **gemma-3-4b-it** – Did not perform well.
- ❌ **qwen3-vl-2b-instruct** – Did not perform well.
- ❌ **qwen3-vl-4b-instruct** – Did not perform well.
- ❌ **qwen3-14b** – Did not perform well.
- ✅ **qwen3-coder-reap-25b-a3b-i1** – Performed decently; best choice for this setup. Run with 64k context size.

## Usage

```bash
# Start the sandbox services
docker-compose up -d localai searchmcp

# Build and run the agent container
docker-compose run --rm --build agent
```

After startup you need to download qwen3-coder-reap-25b-a3b-i1 in localai and set its context size to 65536.

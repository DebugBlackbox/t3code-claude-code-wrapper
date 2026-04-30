# t3code-claude-code-wrapper

Remotely access Claude Code from the t3code UI via a self-hosted Docker container.

## What's inside

| File | Purpose |
|---|---|
| `Dockerfile` | `node:24-slim` image with Claude Code CLI and `t3` pre-installed |
| `compose.yaml` | Runs `npx t3 server --port 3000`, persists workspace in a named volume |
| `entrypoint.sh` | Runs as root: blocks domains, sets up Claude, drops to configured user via gosu |
| `.env.example` | Template for all supported environment variables |

## Prerequisites

- Docker + Docker Compose
- An Anthropic API key (`sk-ant-api03-*`) from [console.anthropic.com](https://console.anthropic.com) → API Keys

## Setup

1. Copy the env template and fill in your values:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env`:

   ```bash
   ANTHROPIC_API_KEY=sk-ant-api03-...

   # Optional overrides
   RUN_USER=t3user          # user the server runs as (created automatically)
   RUN_AS_ROOT=false        # set true to run as root instead

   BLOCKED_DOMAINS=facebook.com,reddit.com  # comma-separated, no spaces
   ```

3. Build and start:

   ```bash
   docker compose up --build
   ```

4. Open t3code and point it at `http://localhost:3000`.

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `ANTHROPIC_API_KEY` | — | Anthropic API key, passed directly to Claude Code |
| `RUN_USER` | `t3user` | Unix user the server process runs as; created at startup if missing |
| `RUN_AS_ROOT` | `false` | Set `true` to skip user creation and run as root |
| `BLOCKED_DOMAINS` | — | Comma-separated domains routed to `0.0.0.0` via `/etc/hosts` |

## Domain blocking

Domains listed in `BLOCKED_DOMAINS` are added to `/etc/hosts` before the server starts. Both the bare domain and `www.` variant are blocked. Connections fail immediately.

## Rebuilding from scratch

```bash
docker compose down -v
docker compose up --build
```

## Deploying with Dokploy

Uncomment the `networks` block in `compose.yaml` to attach the container to `dokploy-network`, then add the service in Dokploy pointing to port `3000`.

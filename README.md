# t3code-claude-code-wrapper

Remotely access Claude Code from the t3code UI via a self-hosted Docker container.

## What's inside

| File | Purpose |
|---|---|
| `Dockerfile` | `node:24-slim` image with Claude Code CLI and `t3` pre-installed |
| `compose.yaml` | Runs `npx t3 server --port 3000`, persists workspace in a named volume |
| `entrypoint.sh` | Blocks domains (root only), writes Claude onboarding settings, then execs the command |
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
   RUN_USER=t3user          # user created at build time; set to "root" to run as root
   GRANT_SUDO=false         # set true to give RUN_USER passwordless sudo

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
| `RUN_USER` | `t3user` | Unix user created at **build time** and used to run the server. Set to `root` to run as root. |
| `GRANT_SUDO` | `false` | Set `true` to give `RUN_USER` passwordless sudo. Requires rebuild. Has no effect when `RUN_USER=root`. |
| `BLOCKED_DOMAINS` | — | Comma-separated domains routed to `0.0.0.0` via `/etc/hosts`. |

## Domain blocking

Domains listed in `BLOCKED_DOMAINS` are added to `/etc/hosts` before the server starts. Both the bare domain and `www.` variant are blocked. Connections fail immediately.

> **Note:** The entrypoint always starts as root to apply `/etc/hosts` changes, then drops to `RUN_USER`. Domain blocking works regardless of which user the server runs as.

## Rebuilding from scratch

```bash
docker compose down -v
docker compose up --build
```

## Deploying with Dokploy

Uncomment the `networks` block in `compose.yaml` to attach the container to `dokploy-network`, then add the service in Dokploy pointing to port `3000`.

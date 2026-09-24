# OpenWA MCP setup

Connects Claude Code (opened in this repo) to a self-hosted [OpenWA](https://github.com/rmyndharis/OpenWA)
WhatsApp gateway over MCP. The server entry lives in `.mcp.json`; the API key is read from your
environment and is never committed.

## 1. Run OpenWA with MCP enabled

```bash
git clone https://github.com/rmyndharis/OpenWA.git
cd OpenWA
MCP_ENABLED=true docker compose up -d
```

One `up` is enough. `MCP_ENABLED` is read when the container is created, so if OpenWA is already
running without it, the same command recreates `openwa-api` with MCP turned on. The first run builds
the image from source and takes a while.

Check it is up: `curl -f http://localhost:2785/api/health/ready`. Dashboard: http://localhost:2785.

By default MCP mounts only the 25 **read-only** tools. To let the agent send messages and manage
groups (51 tools), add `MCP_READONLY=false`. Keep it read-only unless you actually need writes.

## 2. Get a key for the agent

On first start OpenWA seeds an **admin** key, printed in the logs and saved inside the container:

```bash
docker compose logs openwa-api | grep -i "api key"
docker exec openwa-api cat /app/data/.api-key
```

Don't hand the admin key to the agent. Use it once to mint a dedicated key: role `operator` at most
(`viewer` if read-only), scoped to the session(s) the agent needs, and **no** `allowedIps`
(MCP rejects IP-restricted keys). Create it from the dashboard or `POST /api/auth/api-keys`.
The plaintext key is shown only once.

## 3. Point Claude Code at it

```bash
export OPENWA_API_KEY=<the agent key>
# optional, if OpenWA isn't on localhost:2785
export OPENWA_MCP_URL=http://my-host:2785/mcp
claude
```

Approve the `openwa` project server when prompted, then run `/mcp` to confirm it's connected.

## Security

- `/mcp` is bound to `127.0.0.1` by the stock compose file. Don't expose it to the internet without
  an authenticating proxy in front.
- Tune `MCP_RATE_LIMIT_MAX` / `MCP_RATE_LIMIT_WINDOW_MS` (default 60 calls per 60s per key).
- Rotate by creating a new key and deleting the old one.

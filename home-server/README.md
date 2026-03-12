# Home Server Stack

This folder is a cleaned-up compose setup for a small home server or always-on lab box.

It is intentionally narrower than the repo's original dev stack:

- Kept by default: PostgreSQL, Redis, MailHog
- Optional dashboard profile: Portainer, Netdata
- Optional profiles: MySQL, MongoDB, Kafka + Kafka UI, Elasticsearch + Kibana + APM Server
- Removed from this baseline: Vault dev mode, Kafdrop, Redis Insight, Pyroscope

## Why this version exists

The original compose files in this repo are useful for local development, but they are weak defaults for a long-running home server:

- several services expose wide-open dev credentials
- some images use `latest`
- everything starts at once, including heavy services you may not need
- secret handling is mixed into the compose files

This folder tightens that up by:

- moving passwords and ports into `.env`
- keeping the default stack small
- making heavier services opt-in through profiles
- leaving passwords explicit so you can harden before exposing services

## Quick start

```bash
cd /Users/riskiramdan/coding-tools/home-server
cp .env.example .env
make up
```

Default startup:

- PostgreSQL on `SERVER_IP:5432`
- Redis on `SERVER_IP:6379`
- MailHog SMTP on `SERVER_IP:1025`
- MailHog UI on `http://SERVER_IP:8025`

## Optional profiles

Start baseline plus one optional group:

```bash
make up-dashboard
make up-mysql
make up-mongo
make up-messaging
make up-observability
```

Start everything:

```bash
make up-full
```

Restart one app:

```bash
make restart-postgres
make restart-portainer
make restart-netdata
```

Or use the generic target:

```bash
make service-restart SERVICE=redis
make service-logs SERVICE=kafka
make service-ps SERVICE=mailhog
```

You can also use plain compose commands:

```bash
docker compose --env-file .env -f compose.yaml --profile messaging up -d
```

If you prefer Podman:

```bash
make COMPOSE="podman compose" up
```

## Dashboard access

After `make up-dashboard`:

- Portainer: `https://SERVER_IP:9443`
- Netdata: `http://SERVER_IP:19999`

Portainer is the Docker management UI.
Netdata is the host and container metrics UI.

## Remote Access With Tailscale

If Tailscale is already installed on the server, use the dashboard override instead of exposing everything broadly:

```bash
make up-dashboard-tailscale
```

That uses the same dashboard stack and keeps Portainer explicitly bound on the server network.

Then access it using the server's Tailscale IP:

- Portainer: `https://TAILSCALE_IP:9443`
- Netdata: `http://TAILSCALE_IP:19999`

Notes:

- `Netdata` already uses host networking, so it is reachable on the server's interfaces, including Tailscale.
- PostgreSQL, Redis, MySQL, MongoDB, and the other published services are reachable on the server interfaces, including Tailscale, LAN, and any public-facing interface your firewall/router exposes.
- If you do not want services exposed broadly, tighten your host firewall immediately.

## Practical notes

- Change every password in `.env` before leaving this stack running.
- If you want external access, put a reverse proxy in front of the web UIs instead of publishing databases directly.
- Elasticsearch is the heaviest part of this stack. Only enable the observability profile if you need it.
- Kafka is useful for development or queue experiments, but it is unnecessary overhead for most home setups.
- `Portainer` and `Netdata` assume Docker is available at `/var/run/docker.sock`. They are not portable to Podman without changes.
- `Netdata` uses `network_mode: host` per the official Docker guidance so it can observe host networking properly. That means its dashboard listens on the host directly on port `19999`; keep your firewall tight if the server is reachable outside your LAN.
- This compose now publishes ports on `0.0.0.0` by default. Treat the server firewall as mandatory, not optional.

## Recommended baseline

For most home-lab use cases, start with:

- PostgreSQL
- Redis
- MailHog

Then add only what your workloads actually need.

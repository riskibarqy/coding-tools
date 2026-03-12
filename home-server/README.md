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
- binding ports to `127.0.0.1` by default
- keeping the default stack small
- making heavier services opt-in through profiles

## Quick start

```bash
cd /Users/riskiramdan/coding-tools/home-server
cp .env.example .env
make up
```

Default startup:

- PostgreSQL on `127.0.0.1:5432`
- Redis on `127.0.0.1:6379`
- MailHog SMTP on `127.0.0.1:1025`
- MailHog UI on `http://127.0.0.1:8025`

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

- Portainer: `https://127.0.0.1:9443`
- Netdata: `http://SERVER_IP:19999`

Portainer is the Docker management UI.
Netdata is the host and container metrics UI.

## Practical notes

- Change every password in `.env` before leaving this stack running.
- Keep the `127.0.0.1:` bindings unless you really need LAN exposure.
- If you want external access, put a reverse proxy in front of the web UIs instead of publishing databases directly.
- Elasticsearch is the heaviest part of this stack. Only enable the observability profile if you need it.
- Kafka is useful for development or queue experiments, but it is unnecessary overhead for most home setups.
- `Portainer` and `Netdata` assume Docker is available at `/var/run/docker.sock`. They are not portable to Podman without changes.
- `Netdata` uses `network_mode: host` per the official Docker guidance so it can observe host networking properly. That means its dashboard listens on the host directly on port `19999`; keep your firewall tight if the server is reachable outside your LAN.

## Recommended baseline

For most home-lab use cases, start with:

- PostgreSQL
- Redis
- MailHog

Then add only what your workloads actually need.

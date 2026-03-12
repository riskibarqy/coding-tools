# Home Server Stack

This folder is a cleaned-up compose setup for a small home server or always-on lab box.

It is intentionally narrower than the repo's original dev stack:

- Kept by default: PostgreSQL, Redis, MailHog
- Optional dashboard profile: Portainer, Netdata, Redis Insight
- Optional portal profile: Homarr
- Optional profiles: MySQL, MongoDB, Kafka + Kafka UI, Elasticsearch + Kibana + APM Server, Grafana + Prometheus + blackbox_exporter + Alertmanager + exporters, OpenTelemetry Collector + Tempo, Caddy, restic backups
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
make up-portal
make up-mysql
make up-mongo
make up-messaging
make up-observability
make up-monitoring
make up-otel
make up-edge
make up-backup
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
make restart-grafana
make restart-otel-collector
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
- Redis Insight: `http://SERVER_IP:5540`

After `make up-portal`:

- Homarr: `http://SERVER_IP:7575`

After `make up-monitoring`:

- Grafana: `http://SERVER_IP:3000`
- Prometheus: `http://SERVER_IP:9090`
- Alertmanager: `http://SERVER_IP:9093`

Portainer is the Docker management UI.
Netdata is the host and container metrics UI.
Redis Insight is the practical Redis UI for browsing keys, memory, commands, and Redis-specific diagnostics.
Homarr is the homelab portal for launching and organizing your services.
Grafana is the main dashboard for Prometheus metrics and Tempo traces.
Blackbox Exporter probes services from the outside-in.
Alertmanager handles alert routing and silencing, and is now wired for Telegram notifications.

## Caddy Hostnames

The default Caddy hostnames use `.home`, not `.local`, to avoid mDNS conflicts.

Add this on the client machine you use to access the server:

```text
100.127.230.111 homarr.home grafana.home prometheus.home alertmanager.home mailhog.home redisinsight.home kafka.home kibana.home netdata.home portainer.home
```

Then access:

- `http://homarr.home:8088`
- `http://grafana.home:8088`
- `http://prometheus.home:8088`
- `http://alertmanager.home:8088`
- `http://mailhog.home:8088`
- `http://redisinsight.home:8088`
- `http://kafka.home:8088`
- `http://kibana.home:8088`
- `http://netdata.home:8088`
- `http://portainer.home:8088`

Notes:

- `netdata.home` proxies to the host-level Netdata listener through Docker's host gateway mapping.
- `kibana.home` only works when the `observability` profile is running.
- `kafka.home` only works when the `messaging` profile is running.
- `redisinsight.home` only works when the `dashboard` profile is running.
- `homarr.home` only works when the `portal` profile is running.

## Remote Access With Tailscale

All published ports in this stack are bound on the server interfaces, so if Tailscale is installed you can connect with the server's Tailscale IP directly.

Examples:

- Portainer: `https://TAILSCALE_IP:9443`
- Netdata: `http://TAILSCALE_IP:19999`
- Grafana: `http://TAILSCALE_IP:3000`
- Prometheus: `http://TAILSCALE_IP:9090`
- PostgreSQL: `TAILSCALE_IP:5432`

Notes:

- `Netdata` already uses host networking, so it is reachable on the server's interfaces, including Tailscale.
- PostgreSQL, Redis, MySQL, MongoDB, and the other published services are reachable on the server interfaces, including Tailscale, LAN, and any public-facing interface your firewall/router exposes.
- Grafana, Prometheus, and the OTLP ingest ports are also published on the server interfaces by default.
- Alertmanager and Caddy are also published on the server interfaces by default.
- If you do not want services exposed broadly, tighten your host firewall immediately.

## Practical notes

- Change every password in `.env` before leaving this stack running.
- If you want external access, put a reverse proxy in front of the web UIs instead of publishing databases directly.
- Elasticsearch is the heaviest part of this stack. Only enable the observability profile if you need it.
- Kafka is useful for development or queue experiments, but it is unnecessary overhead for most home setups.
- Prometheus + Grafana + Tempo adds another monitoring path next to Elastic. That is intentional here, but it does increase RAM usage.
- Alertmanager is configured for Telegram using a bot token file in `home-server/alertmanager/secrets/telegram_bot_token`.
- Replace the bot token file and set the real `chat_id` value in [alertmanager.yml](/Users/riskiramdan/coding-tools/home-server/alertmanager/alertmanager.yml) before relying on alerts. For group chats, Telegram chat IDs are often negative integers.
- The default restic config backs up into a local Docker volume. That is good for proving the workflow, but it is not a real off-host backup until you point `RESTIC_REPOSITORY` at external storage.
- `Portainer` and `Netdata` assume Docker is available at `/var/run/docker.sock`. They are not portable to Podman without changes.
- `Netdata` uses `network_mode: host` per the official Docker guidance so it can observe host networking properly. That means its dashboard listens on the host directly on port `19999`; keep your firewall tight if the server is reachable outside your LAN.
- This compose now publishes ports on `0.0.0.0` by default. Treat the server firewall as mandatory, not optional.

## Profiles and Ports

- `dashboard`
  - `portainer` on `9443`
  - `netdata` on `19999`
  - `redis-insight` on `5540`
- `portal`
  - `homarr` on `7575`
- `observability`
  - `elasticsearch` on `9200`
  - `kibana` on `5601`
  - `apm-server` on `8200`
- `monitoring`
  - `grafana` on `3000`
  - `prometheus` on `9090`
  - `alertmanager` on `9093`
  - `blackbox-exporter` internal on `9115`
  - `node-exporter` internal on `9100`
  - `cadvisor` internal on `8080`
  - `redis-exporter` internal on `9121`
- `otel`
  - `otel-collector` on `4317` and `4318`
  - `tempo` internal on `3200`
- `edge`
  - `caddy` on `8088`
- `backup`
  - `restic` background worker using `RESTIC_REPOSITORY`

## Data Flow

- Host metrics: `node-exporter -> prometheus -> grafana`
- Container metrics: `cadvisor -> prometheus -> grafana`
- Redis metrics: `redis-exporter -> prometheus -> grafana`
- Active probes: `blackbox-exporter -> prometheus -> alert rules -> alertmanager`
- OTLP traces: `app -> otel-collector -> tempo -> grafana`
- Elastic APM traces and APM data: `app -> apm-server -> elasticsearch -> kibana`

## Telegram Alerts

Edit these after cloning on the server:

- [telegram_bot_token](/Users/riskiramdan/coding-tools/home-server/alertmanager/secrets/telegram_bot_token)
- [alertmanager.yml](/Users/riskiramdan/coding-tools/home-server/alertmanager/alertmanager.yml)

Then restart Alertmanager:

```bash
cd /Users/riskiramdan/coding-tools/home-server
make restart-alertmanager
```

The message format is defined in:

- [telegram.tmpl](/Users/riskiramdan/coding-tools/home-server/alertmanager/templates/telegram.tmpl)

Note:

- `make up-monitoring` does not require `make up-otel`
- Prometheus in this baseline scrapes host, container, and Redis metrics only
- Tempo is still available to Grafana as a trace datasource when `make up-otel` is running

## Sentry

I did not inline Sentry into this compose file.

Reason:

- official self-hosted Sentry is a large multi-service stack with its own bootstrap, install script, and frequent compose/config updates
- forcing it into this compose would create a fragile fork that will be painful to maintain

Official sources:

- [Self-hosted Sentry repo](https://github.com/getsentry/self-hosted)
- [Self-hosted releases](https://github.com/getsentry/self-hosted/releases)

Practical recommendation:

- deploy Sentry in a separate directory and keep this `home-server` stack for shared infra, dashboards, and optional Elastic/Grafana tooling
- if you want, I can scaffold a separate `sentry-self-hosted/` guide in this repo next, with the exact clone/install/update flow and Tailscale access notes

## Recommended baseline

For most home-lab use cases, start with:

- PostgreSQL
- Redis
- MailHog

Then add only what your workloads actually need.

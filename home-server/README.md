# Home Server Stack

This folder is a cleaned-up compose setup for a small home server or always-on lab box.

It is intentionally narrower than the repo's original dev stack:

- Kept by default: PostgreSQL, Redis, MailHog
- Optional dashboard profile: Portainer, Netdata, Redis Insight
- Optional portal profile: Homarr
- Optional bugsink profile: Bugsink error tracking
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
make up-bugsink
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

After `make up-bugsink`:

- Bugsink: `http://SERVER_IP:8010`

After `make up-monitoring`:

- Grafana: `http://SERVER_IP:3000`
- Prometheus: `http://SERVER_IP:9090`
- Alertmanager: `http://SERVER_IP:9093`

Portainer is the Docker management UI.
Netdata is the host and container metrics UI.
Redis Insight is the practical Redis UI for browsing keys, memory, commands, and Redis-specific diagnostics.
Homarr is the homelab portal for launching and organizing your services.
Bugsink is the lighter Sentry-like error tracking UI for app exceptions.
Grafana is the main dashboard for Prometheus metrics and Tempo traces.
Blackbox Exporter probes services from the outside-in.
Alertmanager handles alert routing and silencing, and is now wired for Telegram notifications.
PostgreSQL metrics are collected through `postgres-exporter` and exposed in Grafana.

## Caddy Hostnames

The default Caddy hostnames use `.home`, not `.local`, to avoid mDNS conflicts.

Add this on the client machine you use to access the server:

```text
100.127.230.111 homarr.home grafana.home prometheus.home alertmanager.home mailhog.home redisinsight.home bugsink.home kafka.home kibana.home netdata.home portainer.home
```

Then access:

- `http://homarr.home:8088`
- `http://grafana.home:8088`
- `http://prometheus.home:8088`
- `http://alertmanager.home:8088`
- `http://mailhog.home:8088`
- `http://redisinsight.home:8088`
- `http://bugsink.home:8088`
- `http://kafka.home:8088`
- `http://kibana.home:8088`
- `http://netdata.home:8088`
- `http://portainer.home:8088`

Notes:

- `netdata.home` proxies to `CADDY_NETDATA_UPSTREAM`.
- On Linux, if `host.docker.internal:19999` times out, set `CADDY_NETDATA_UPSTREAM` in `.env` to the server's reachable IP, for example `100.127.230.111:19999`.
- `kibana.home` only works when the `observability` profile is running.
- `kafka.home` only works when the `messaging` profile is running.
- `redisinsight.home` only works when the `dashboard` profile is running.
- `bugsink.home` only works when the `bugsink` profile is running.
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
- If you access Portainer through Caddy, set `PORTAINER_TRUSTED_ORIGINS` in `.env` to the hostname you use, for example `portainer.home`. Otherwise Portainer can reject actions with `Forbidden - origin invalid`.
- Bugsink is wired to PostgreSQL instead of SQLite because Bugsink's official docs advise against SQLite-on-Docker-volume setups for anything production-like.
- `Netdata` uses `network_mode: host` per the official Docker guidance so it can observe host networking properly. That means its dashboard listens on the host directly on port `19999`; keep your firewall tight if the server is reachable outside your LAN.
- This compose now publishes ports on `0.0.0.0` by default. Treat the server firewall as mandatory, not optional.
- Kafka, Kafka UI, Kibana, and Mongo now have conservative memory caps in `.env`. If your server is small, keep those defaults; if workloads become slow under load, raise them intentionally instead of leaving the JVM defaults unbounded.

## Profiles and Ports

- `dashboard`
  - `portainer` on `9443`
  - `netdata` on `19999`
  - `redis-insight` on `5540`
- `portal`
  - `homarr` on `7575`
- `bugsink`
  - `bugsink` on `8010`
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
  - `postgres-exporter` internal on `9187`
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
- PostgreSQL metrics: `postgres-exporter -> prometheus -> grafana`
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
- Prometheus in this baseline scrapes host, container, Redis, and PostgreSQL metrics, plus blackbox probes for configured URLs
- Tempo is still available to Grafana as a trace datasource when `make up-otel` is running

## App And Postgres Monitoring

The monitoring profile now includes:

- `postgres-exporter` for PostgreSQL metrics
- blackbox probes for these app URLs:
  - `https://fantasy-league-fe.vercel.app/`
  - `https://anubis-rw84mq.fly.dev`
  - `https://fantasy-league.fly.dev`

After restarting the monitoring stack, Grafana will provision an additional dashboard in the `Home Server` folder:

- `Apps and Postgres`

It includes:

- app up/down status for the frontend and both backends
- probe duration for the app URLs
- PostgreSQL exporter status
- PostgreSQL active connections
- PostgreSQL transactions per second
- PostgreSQL database size

If you later change app URLs, update them in [prometheus.yml](/Users/riskiramdan/coding-tools/home-server/prometheus/prometheus.yml) and restart Prometheus.

## Bugsink

Bugsink is included as an optional `bugsink` profile.

Before first startup, create its PostgreSQL database and user inside the existing `postgres` container:

```bash
cd /Users/riskiramdan/coding-tools/home-server
docker compose --env-file .env -f compose.yaml exec -it postgres psql -U app -d postgres
```

Then run:

```sql
CREATE USER bugsink WITH PASSWORD 'change-me-bugsink-db';
CREATE DATABASE bugsink OWNER bugsink;
```

After that, set these values in your real `.env`:

- `BUGSINK_DB_NAME`
- `BUGSINK_DB_USER`
- `BUGSINK_DB_PASSWORD`
- `BUGSINK_SECRET_KEY`
- `BUGSINK_CREATE_SUPERUSER`
- `BUGSINK_BASE_URL`

Then start it:

```bash
make up-bugsink
make up-edge
```

Access:

- direct: `http://SERVER_IP:8010`
- through Caddy: `http://bugsink.home`

If you later move Caddy to HTTPS, change `BUGSINK_BASE_URL` to `https://bugsink.home` and stop relying on `BUGSINK_BEHIND_PLAIN_HTTP_PROXY=true`.

### Bugsink Email

Bugsink email is configured through these `.env` values:

- `BUGSINK_EMAIL_HOST`
- `BUGSINK_EMAIL_HOST_USER`
- `BUGSINK_EMAIL_HOST_PASSWORD`
- `BUGSINK_EMAIL_PORT`
- `BUGSINK_EMAIL_USE_TLS`
- `BUGSINK_EMAIL_USE_SSL`
- `BUGSINK_EMAIL_TIMEOUT`
- `BUGSINK_DEFAULT_FROM_EMAIL`

For local testing with MailHog in this stack, use:

```env
BUGSINK_EMAIL_HOST=mailhog
BUGSINK_EMAIL_PORT=1025
BUGSINK_EMAIL_USE_TLS=false
BUGSINK_EMAIL_USE_SSL=false
BUGSINK_EMAIL_HOST_USER=
BUGSINK_EMAIL_HOST_PASSWORD=
BUGSINK_DEFAULT_FROM_EMAIL=Bugsink <bugsink@home.local>
```

Then restart Bugsink:

```bash
make restart-bugsink
```

You can inspect the test messages in MailHog:

- `http://SERVER_IP:8025`
- or `http://mailhog.home`

For real delivery through an SMTP provider, set the provider's SMTP host, username, password, sender address, and either TLS or SSL according to the provider's documentation, then restart Bugsink.

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

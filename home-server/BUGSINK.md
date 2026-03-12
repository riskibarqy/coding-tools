# Bugsink Notes

Bugsink is now wired into `compose.yaml` as the optional `bugsink` profile.

This setup uses:

- `bugsink/bugsink:2.0.14`
- PostgreSQL through the existing `postgres` service
- direct access on host port `8010`
- optional reverse proxy access through `bugsink.home` in Caddy

Important notes:

- create the PostgreSQL user and database before first startup
- set a real `BUGSINK_SECRET_KEY`
- set a real `BUGSINK_CREATE_SUPERUSER`
- if you access it through plain HTTP behind Caddy, keep `BUGSINK_BEHIND_PLAIN_HTTP_PROXY=true`
- if you later move Caddy to HTTPS, switch `BUGSINK_BASE_URL` to `https://...` and stop using the plain HTTP proxy flag

Official docs:

- [Bugsink docs](https://www.bugsink.com/docs/)
- [Docker Compose install](https://www.bugsink.com/docs/docker-compose-install/)
- [PostgreSQL docs](https://www.bugsink.com/docs/postgresql/)
- [Proxy headers docs](https://www.bugsink.com/docs/proxy-headers/)
- [Sentry SDK compatibility](https://www.bugsink.com/connect-any-application/)

See [README.md](/Users/riskiramdan/coding-tools/home-server/README.md) for the exact startup flow in this repo.

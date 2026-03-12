# Bugsink Notes

Bugsink is the lighter Sentry-like option I would choose for this server, but I have not wired it into `compose.yaml` yet.

Reason:

- the official docs confirm Docker Compose support, but the environment and storage settings needed for a safe default were not sufficiently discoverable from the available docs crawl
- I do not want to invent a half-correct compose service for your error tracking stack

Official docs:

- [Bugsink docs](https://www.bugsink.com/docs/)
- [Docker Compose install](https://www.bugsink.com/docs/docker-compose-install/)
- [Sentry SDK compatibility](https://www.bugsink.com/connect-any-application/)

Recommended next step for Bugsink:

1. Decide whether you want the simple SQLite deployment or a database-backed deployment.
2. Share the exact config path or compose example you want to follow from the official docs.
3. Then wire it into this repo as a dedicated `bugsink` profile.

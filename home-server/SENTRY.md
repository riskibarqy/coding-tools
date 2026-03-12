# Sentry Self-Hosted Notes

Sentry is intentionally not embedded into `compose.yaml` here.

The official self-hosted deployment is its own multi-service stack with its own release cadence, bootstrap, and config updates. Maintaining a hand-merged version inside this home-server compose would be fragile.

Official sources:

- [getsentry/self-hosted](https://github.com/getsentry/self-hosted)
- [Latest self-hosted releases](https://github.com/getsentry/self-hosted/releases)

Recommended deployment shape:

1. Clone the official self-hosted repo into a separate directory on the server.
2. Check out a specific release tag.
3. Run the official `./install.sh`.
4. Run `docker compose up -d`.
5. Expose only the Sentry web endpoint over Tailscale or a reverse proxy.

Suggested commands:

```bash
cd /opt
git clone https://github.com/getsentry/self-hosted.git sentry-self-hosted
cd sentry-self-hosted
git checkout 25.12.1
./install.sh
docker compose up -d
```

Operational notes:

- Sentry is heavy. Plan for significantly more RAM and disk than the current home-server baseline.
- Keep Sentry isolated from your main compose file so upgrades stay aligned with the official release instructions.
- Do not expose Sentry's internal services directly. Only expose the web endpoint you actually use.

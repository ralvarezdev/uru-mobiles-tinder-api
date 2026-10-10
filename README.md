# uru-mobiles-tinder-api

Main Docker Compose deployment for the Tinder-style App, built for the Mobile Development college course. It wires together auth, user, social, chats and file-storage microservices (consumed by `uru-mobiles-tinder-app`), an internal mailer worker, a public Nginx edge, and a full observability stack.

## Architecture

Each service is its own repository, pulled in as a git submodule: `connect-auth` (JWT Ed25519, 2FA), `connect-user`, `connect-social` (matching, backed by Neo4j), `connect-sync-chats`, `websockets-realtime-chats` (realtime chat, also a standalone repo), `http-files-server`, `worker-internal-mailer` (RabbitMQ consumer, also standalone), `api.ralvarez.app` (Nginx edge), plus `sql-*` migration files.

Infrastructure in `docker-compose.yml`: PostgreSQL (per-service databases), Redis (token storage, per-service ACLs), RabbitMQ (mail queues), Neo4j (social graph, HTTP 7474 / Bolt 7687, separate admin/user/social credentials), and Grafana + Prometheus + Loki + Promtail + Node Exporter + cAdvisor.

## Services

| Container | Port |
|---|---|
| `api-ralvarez-app` | 9000 (Nginx) |
| `connect-auth` | 9001 |
| `connect-user` | 9002 |
| `connect-sync-chats` | 9003 |
| `connect-social` | 9004 |
| `websockets-realtime-chats` | 9005 |
| `http-files-server` | 9006 |
| `neo4j` | 7474 / 7687 |
| `grafana` | 3000 |
| `postgres`, `redis`, `rabbitmq`, `worker-internal-mailer`, `prometheus`, `node-exporter`, `cadvisor`, `loki`, `promtail` | internal only |

## Configuration

Copy `.env.example` to `.env`. Groups: per-service `*_MODE` flags, `DOMAIN`; Postgres per-service `POSTGRES_*_DB_*`; Redis; RabbitMQ (mail exchange/queue/routing-key names); Neo4j (`NEO4J_DEFAULT/USER/SOCIAL_USERNAME/PASSWORD`); JWT token durations; internal mailer (MailerSend/Resend); auth settings (bootstrap admin, 2FA, password policy); Grafana admin credentials.

A `GITHUB_TOKEN` build secret is required to build the private submodule images.

## Running

1. `git submodule update --init --recursive` (or `update_submodules.sh`).
2. Generate the JWT key pair: `./generate_keys.sh`.
3. Prepare SQL init files: `./prepare.sh`.
4. Create `.env` from `.env.example` and fill in every variable.
5. `docker compose up --build`.

Cloudflare Tunnel ingress is configured via `cloudflared/config.yml.example` — copy it, set your own tunnel ID/credentials, and never commit the real file.

## Related repositories

- [`uru-mobiles-tinder-app`](https://github.com/ralvarezdev/uru-mobiles-tinder-app) — matching application.
## License

GNU General Public License v3.0 (see `LICENSE`).

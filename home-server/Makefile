COMPOSE ?= docker compose
ENV_FILE ?= .env
COMPOSE_FILE ?= compose.yaml
COMPOSE_CMD = $(COMPOSE) --env-file $(ENV_FILE) -f $(COMPOSE_FILE)
SERVICE ?= postgres

.PHONY: help up up-dashboard up-mysql up-mongo up-messaging up-observability up-monitoring up-otel up-edge up-backup up-full down restart ps logs pull config service-up service-down service-restart service-logs service-ps restart-postgres restart-redis restart-mailhog restart-portainer restart-netdata restart-redis-insight restart-mysql restart-mongo restart-kafka restart-kafka-ui restart-elasticsearch restart-kibana restart-apm-server restart-grafana restart-prometheus restart-node-exporter restart-cadvisor restart-blackbox-exporter restart-alertmanager restart-redis-exporter restart-otel-collector restart-tempo restart-caddy restart-restic

help:
	@echo "Targets:"
	@echo "  make up                - Start baseline services (postgres, redis, mailhog)"
	@echo "  make up-dashboard      - Start Portainer + Netdata"
	@echo "  make up-mysql          - Start baseline + MySQL"
	@echo "  make up-mongo          - Start baseline + MongoDB"
	@echo "  make up-messaging      - Start baseline + Kafka + Kafka UI"
	@echo "  make up-observability  - Start baseline + Elasticsearch + Kibana + APM Server"
	@echo "  make up-monitoring     - Start Grafana + Prometheus + blackbox_exporter + Alertmanager + exporters"
	@echo "  make up-otel           - Start OpenTelemetry Collector + Tempo"
	@echo "  make up-edge           - Start Caddy reverse proxy"
	@echo "  make up-backup         - Start restic backup worker"
	@echo "  make up-full           - Start everything in this folder"
	@echo "  make down              - Stop and remove containers"
	@echo "  make restart           - Restart all running services in this compose project"
	@echo "  make ps                - Show container status"
	@echo "  make logs              - Follow logs"
	@echo "  make pull              - Pull images"
	@echo "  make config            - Render final compose config"
	@echo "  make service-restart SERVICE=postgres - Restart one service"
	@echo "  make service-logs SERVICE=postgres    - Follow logs for one service"
	@echo "  make restart-postgres  - Restart PostgreSQL"
	@echo "  make restart-portainer - Restart Portainer"
	@echo "  make restart-netdata   - Restart Netdata"
	@echo "  make restart-redis-insight - Restart Redis Insight"
	@echo ""
	@echo "Variables:"
	@echo "  COMPOSE=$(COMPOSE)"
	@echo "  ENV_FILE=$(ENV_FILE)"
	@echo "  COMPOSE_FILE=$(COMPOSE_FILE)"
	@echo "  SERVICE=$(SERVICE)"
	@echo "  PORTAINER_BIND_IP is read from $(ENV_FILE)"

up:
	$(COMPOSE_CMD) up -d

up-dashboard:
	$(COMPOSE_CMD) --profile dashboard up -d

up-mysql:
	$(COMPOSE_CMD) --profile mysql up -d

up-mongo:
	$(COMPOSE_CMD) --profile mongo up -d

up-messaging:
	$(COMPOSE_CMD) --profile messaging up -d

up-observability:
	$(COMPOSE_CMD) --profile observability up -d

up-monitoring:
	$(COMPOSE_CMD) --profile monitoring up -d

up-otel:
	$(COMPOSE_CMD) --profile otel up -d

up-edge:
	$(COMPOSE_CMD) --profile edge up -d

up-backup:
	$(COMPOSE_CMD) --profile backup up -d

up-full:
	$(COMPOSE_CMD) --profile dashboard --profile mysql --profile mongo --profile messaging --profile observability --profile monitoring --profile otel --profile edge --profile backup up -d

down:
	$(COMPOSE_CMD) down

restart:
	$(COMPOSE_CMD) restart

ps:
	$(COMPOSE_CMD) ps

logs:
	$(COMPOSE_CMD) logs -f --tail=200

pull:
	$(COMPOSE_CMD) pull

config:
	$(COMPOSE_CMD) config

service-up:
	$(COMPOSE_CMD) up -d $(SERVICE)

service-down:
	$(COMPOSE_CMD) stop $(SERVICE)

service-restart:
	$(COMPOSE_CMD) restart $(SERVICE)

service-logs:
	$(COMPOSE_CMD) logs -f --tail=200 $(SERVICE)

service-ps:
	$(COMPOSE_CMD) ps $(SERVICE)

restart-postgres: SERVICE=postgres
restart-postgres: service-restart

restart-redis: SERVICE=redis
restart-redis: service-restart

restart-mailhog: SERVICE=mailhog
restart-mailhog: service-restart

restart-portainer: SERVICE=portainer
restart-portainer: service-restart

restart-netdata: SERVICE=netdata
restart-netdata: service-restart

restart-redis-insight: SERVICE=redis-insight
restart-redis-insight: service-restart

restart-mysql: SERVICE=mysql
restart-mysql: service-restart

restart-mongo: SERVICE=mongo
restart-mongo: service-restart

restart-kafka: SERVICE=kafka
restart-kafka: service-restart

restart-kafka-ui: SERVICE=kafka-ui
restart-kafka-ui: service-restart

restart-elasticsearch: SERVICE=elasticsearch
restart-elasticsearch: service-restart

restart-kibana: SERVICE=kibana
restart-kibana: service-restart

restart-apm-server: SERVICE=apm-server
restart-apm-server: service-restart

restart-grafana: SERVICE=grafana
restart-grafana: service-restart

restart-prometheus: SERVICE=prometheus
restart-prometheus: service-restart

restart-node-exporter: SERVICE=node-exporter
restart-node-exporter: service-restart

restart-cadvisor: SERVICE=cadvisor
restart-cadvisor: service-restart

restart-blackbox-exporter: SERVICE=blackbox-exporter
restart-blackbox-exporter: service-restart

restart-alertmanager: SERVICE=alertmanager
restart-alertmanager: service-restart

restart-redis-exporter: SERVICE=redis-exporter
restart-redis-exporter: service-restart

restart-otel-collector: SERVICE=otel-collector
restart-otel-collector: service-restart

restart-tempo: SERVICE=tempo
restart-tempo: service-restart

restart-caddy: SERVICE=caddy
restart-caddy: service-restart

restart-restic: SERVICE=restic
restart-restic: service-restart

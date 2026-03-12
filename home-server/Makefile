COMPOSE ?= docker compose
ENV_FILE ?= .env
COMPOSE_FILE ?= compose.yaml
COMPOSE_CMD = $(COMPOSE) --env-file $(ENV_FILE) -f $(COMPOSE_FILE)
SERVICE ?= postgres

.PHONY: help up up-dashboard up-dashboard-tailscale up-mysql up-mongo up-messaging up-observability up-full down restart ps logs pull config config-tailscale service-up service-down service-restart service-logs service-ps restart-postgres restart-redis restart-mailhog restart-portainer restart-netdata restart-mysql restart-mongo restart-kafka restart-kafka-ui restart-elasticsearch restart-kibana restart-apm-server

help:
	@echo "Targets:"
	@echo "  make up                - Start baseline services (postgres, redis, mailhog)"
	@echo "  make up-dashboard      - Start Portainer + Netdata"
	@echo "  make up-dashboard-tailscale - Start Portainer + Netdata for Tailscale access"
	@echo "  make up-mysql          - Start baseline + MySQL"
	@echo "  make up-mongo          - Start baseline + MongoDB"
	@echo "  make up-messaging      - Start baseline + Kafka + Kafka UI"
	@echo "  make up-observability  - Start baseline + Elasticsearch + Kibana + APM Server"
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

up-dashboard-tailscale:
	PORTAINER_BIND_IP=0.0.0.0 $(COMPOSE_CMD) --profile dashboard up -d

up-mysql:
	$(COMPOSE_CMD) --profile mysql up -d

up-mongo:
	$(COMPOSE_CMD) --profile mongo up -d

up-messaging:
	$(COMPOSE_CMD) --profile messaging up -d

up-observability:
	$(COMPOSE_CMD) --profile observability up -d

up-full:
	$(COMPOSE_CMD) --profile dashboard --profile mysql --profile mongo --profile messaging --profile observability up -d

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

config-tailscale:
	PORTAINER_BIND_IP=0.0.0.0 $(COMPOSE_CMD) --profile dashboard config

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

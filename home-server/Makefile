COMPOSE ?= docker compose
ENV_FILE ?= .env
COMPOSE_FILE ?= compose.yaml
COMPOSE_CMD = $(COMPOSE) --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: help up up-dashboard up-dashboard-tailscale up-mysql up-mongo up-messaging up-observability up-full down ps logs config pull config-tailscale

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
	@echo "  make ps                - Show container status"
	@echo "  make logs              - Follow logs"
	@echo "  make pull              - Pull images"
	@echo "  make config            - Render final compose config"
	@echo ""
	@echo "Variables:"
	@echo "  COMPOSE=$(COMPOSE)"
	@echo "  ENV_FILE=$(ENV_FILE)"
	@echo "  COMPOSE_FILE=$(COMPOSE_FILE)"
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

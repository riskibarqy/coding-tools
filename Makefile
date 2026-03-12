COMPOSE_FILE ?= podman/podman-compose.yml
PODMAN_COMPOSE ?= podman compose -f $(COMPOSE_FILE)
SERVICE ?= mysql
SERVICES ?= postgres mysql redis mongo kafka kafdrop kafka-ui elasticsearch kibana apm-server pyroscope vault mailhog redis-insight

.PHONY: help ensure-dirs up down restart ps logs pull config service-up service-down service-restart service-logs service-ps mysql-up mysql-down mysql-restart mysql-logs mysql-ps mysql-shell mysql-health mysql-reset

help:
	@echo "Targets:"
	@echo "  make up             - Start all services"
	@echo "  make down           - Stop all services and remove containers"
	@echo "  make restart        - Restart all services"
	@echo "  make ps             - Show status of all services"
	@echo "  make logs           - Follow logs for all services"
	@echo "  make pull           - Pull images for all services"
	@echo "  make config         - Render merged compose config"
	@echo "  make service-up SERVICE=kafka      - Start one service"
	@echo "  make service-down SERVICE=kafka    - Stop one service"
	@echo "  make service-restart SERVICE=kafka - Restart one service"
	@echo "  make service-logs SERVICE=kafka    - Follow logs for one service"
	@echo "  make service-ps SERVICE=kafka      - Show one service status"
	@echo "  make mysql-up       - Start MySQL service"
	@echo "  make mysql-down     - Stop MySQL service"
	@echo "  make mysql-restart  - Restart MySQL service"
	@echo "  make mysql-logs     - Follow MySQL logs"
	@echo "  make mysql-ps       - Show MySQL service status"
	@echo "  make mysql-shell    - Open mysql client inside container"
	@echo "  make mysql-health   - Check MySQL health from inside container"
	@echo "  make mysql-reset    - Stop and remove MySQL data volume directory (DANGER)"
	@echo ""
	@echo "Variables:"
	@echo "  COMPOSE_FILE=$(COMPOSE_FILE)"
	@echo "  SERVICE=$(SERVICE)"
	@echo "  SERVICES=$(SERVICES)"

ensure-dirs:
	@mkdir -p podman/data/postgres podman/data/mysql

up: ensure-dirs
	$(PODMAN_COMPOSE) up -d

down:
	$(PODMAN_COMPOSE) down

restart:
	$(PODMAN_COMPOSE) restart $(SERVICES)

ps:
	$(PODMAN_COMPOSE) ps

logs:
	$(PODMAN_COMPOSE) logs -f --tail=200

pull:
	$(PODMAN_COMPOSE) pull

config:
	$(PODMAN_COMPOSE) config

service-up: ensure-dirs
	$(PODMAN_COMPOSE) up -d $(SERVICE)

service-down:
	$(PODMAN_COMPOSE) stop $(SERVICE)

service-restart:
	$(PODMAN_COMPOSE) restart $(SERVICE)

service-logs:
	$(PODMAN_COMPOSE) logs -f --tail=200 $(SERVICE)

service-ps:
	$(PODMAN_COMPOSE) ps $(SERVICE)

mysql-up: SERVICE=mysql
mysql-up: service-up

mysql-down: SERVICE=mysql
mysql-down: service-down

mysql-restart: SERVICE=mysql
mysql-restart: service-restart

mysql-logs: SERVICE=mysql
mysql-logs: service-logs

mysql-ps: SERVICE=mysql
mysql-ps: service-ps

mysql-shell:
	podman exec -it my-mysql mysql -uroot -p$${MYSQL_ROOT_PASSWORD:-changeme}

mysql-health:
	podman exec my-mysql mysqladmin ping -h 127.0.0.1 -uroot -p$${MYSQL_ROOT_PASSWORD:-changeme} --silent && echo "healthy" || (echo "unhealthy" && exit 1)

mysql-reset:
	$(PODMAN_COMPOSE) stop mysql
	rm -rf podman/data/mysql
	@mkdir -p podman/data/mysql
	@echo "MySQL data directory reset: podman/data/mysql"

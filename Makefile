# Balbescraft Minecraft Server Makefile
# =====================================

.PHONY: help build up down start stop restart logs shell console backup clean update rebuild status

# Default target
help:
	@echo "Balbescraft Minecraft Server - Available Commands"
	@echo "================================================="
	@echo ""
	@echo "  make build      - Build the Docker image"
	@echo "  make up         - Start the server (detached)"
	@echo "  make down       - Stop and remove containers"
	@echo "  make start      - Start existing container"
	@echo "  make stop       - Stop the server gracefully"
	@echo "  make restart    - Restart the server"
	@echo "  make logs       - Follow server logs"
	@echo "  make shell      - Open a shell in the container"
	@echo "  make console    - Attach to server console (Ctrl+P Ctrl+Q to detach)"
	@echo "  make backup     - Backup world data"
	@echo "  make clean      - Remove containers and volumes (DESTRUCTIVE)"
	@echo "  make update     - Update and rebuild the server"
	@echo "  make rebuild    - Force rebuild without cache"
	@echo "  make status     - Show container status"
	@echo ""

# Build the Docker image
build:
	docker compose build

# Start the server in detached mode
up:
	@if [ ! -f .env ]; then \
		echo "Creating .env from .env.example..."; \
		cp .env.example .env; \
	fi
	docker compose up -d

# Stop and remove containers
down:
	docker compose down

# Start existing container
start:
	docker compose start

# Stop the server gracefully
stop:
	@echo "Stopping server gracefully..."
	docker compose stop -t 30

# Restart the server
restart: stop start
	@echo "Server restarted"

# Follow server logs
logs:
	docker compose logs -f --tail=100

# Open a shell in the container
shell:
	docker compose exec minecraft /bin/bash

# Attach to server console
console:
	@echo "Attaching to server console..."
	@echo "Press Ctrl+P then Ctrl+Q to detach without stopping"
	docker attach balbescraft

# Backup world data
backup:
	@echo "Creating backup..."
	@mkdir -p backups
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	echo "Backing up world_data..."; \
	docker run --rm \
		-v balbescraft_world:/data:ro \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/world_$$TIMESTAMP.tar.gz -C /data .; \
	echo "Backing up world_nether..."; \
	docker run --rm \
		-v balbescraft_world_nether:/data:ro \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/world_nether_$$TIMESTAMP.tar.gz -C /data .; \
	echo "Backing up world_the_end..."; \
	docker run --rm \
		-v balbescraft_world_the_end:/data:ro \
		-v $$(pwd)/backups:/backup \
		alpine tar czf /backup/world_the_end_$$TIMESTAMP.tar.gz -C /data .; \
	echo "Backup complete: backups/*_$$TIMESTAMP.tar.gz"

# Remove all containers and volumes (DESTRUCTIVE!)
clean:
	@echo "WARNING: This will delete all world data!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	docker compose down -v
	@echo "All containers and volumes removed"

# Update and rebuild the server
update:
	@echo "Updating server..."
	git pull || true
	docker compose build
	docker compose up -d
	@echo "Server updated and restarted"

# Force rebuild without cache
rebuild:
	docker compose build --no-cache
	docker compose up -d

# Show container status
status:
	@echo "Container Status:"
	@docker compose ps
	@echo ""
	@echo "Volume Usage:"
	@docker system df -v 2>/dev/null | grep -E "balbescraft|VOLUME" || docker volume ls | grep balbescraft

# Execute a command in the server
cmd:
	@read -p "Enter command: " command && \
	docker compose exec minecraft bash -c "echo '$$command'"

# Watch logs with filtering
watch-errors:
	docker compose logs -f 2>&1 | grep -i -E "error|warn|exception|fail"

# Quick server info
info:
	@echo "Server: balbescraft"
	@echo "Port: $${SERVER_PORT:-25565}"
	@docker compose ps --format "Status: {{.Status}}" 2>/dev/null || echo "Status: Not running"

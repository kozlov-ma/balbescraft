# Balbescraft Minecraft Server Makefile
# =====================================

# Configuration
PAPER_JAR := paper-1.21.11-72.jar
MIN_RAM := 2G
MAX_RAM := 10G
SERVER_PORT := 25565

# JVM flags (Aikar's flags for optimal performance)
JVM_FLAGS := -Xms$(MIN_RAM) -Xmx$(MAX_RAM) \
	-XX:+UseG1GC \
	-XX:+ParallelRefProcEnabled \
	-XX:MaxGCPauseMillis=200 \
	-XX:+UnlockExperimentalVMOptions \
	-XX:+DisableExplicitGC \
	-XX:+AlwaysPreTouch \
	-XX:G1NewSizePercent=30 \
	-XX:G1MaxNewSizePercent=40 \
	-XX:G1HeapRegionSize=8M \
	-XX:G1ReservePercent=20 \
	-XX:G1HeapWastePercent=5 \
	-XX:G1MixedGCCountTarget=4 \
	-XX:InitiatingHeapOccupancyPercent=15 \
	-XX:G1MixedGCLiveThresholdPercent=90 \
	-XX:G1RSetUpdatingPauseTimePercent=5 \
	-XX:SurvivorRatio=32 \
	-XX:+PerfDisableSharedMem \
	-XX:MaxTenuringThreshold=1 \
	-Dusing.aikars.flags=https://mcflags.emc.gs \
	-Daikars.new.flags=true

.PHONY: help start stop restart setup backup clean logs status install-datapacks

# Default target
help:
	@echo "Balbescraft Minecraft Server - Available Commands"
	@echo "================================================="
	@echo ""
	@echo "  make setup     - Initial server setup (accept EULA, create configs)"
	@echo "  make start     - Start the server in foreground"
	@echo "  make start-bg  - Start the server in background"
	@echo "  make stop      - Stop the background server gracefully"
	@echo "  make restart   - Restart the background server"
	@echo "  make backup    - Backup world data"
	@echo "  make clean     - Remove generated server files (DESTRUCTIVE)"
	@echo "  make logs      - Show recent server logs"
	@echo "  make status    - Check if server is running"
	@echo "  make install-datapacks - Install datapacks from datapacks/ to world/"
	@echo ""

# Initial setup
setup:
	@echo "Setting up Balbescraft server..."
	@echo "eula=true" > eula.txt
	@echo "EULA accepted."
	@mkdir -p world world_nether world_the_end plugins logs
	@if [ ! -f server.properties ]; then \
		cp config/server.properties . 2>/dev/null || echo "server.properties will be generated on first run"; \
	fi
	@$(MAKE) install-datapacks
	@echo ""
	@echo "Setup complete! Run 'make start' to start the server."

# Start server in foreground (interactive)
start: setup
	@echo "Starting Balbescraft server..."
	@echo "Memory: $(MIN_RAM) - $(MAX_RAM)"
	@echo "Port: $(SERVER_PORT)"
	@echo ""
	@echo "Press Ctrl+C to stop the server"
	@echo ""
	java $(JVM_FLAGS) -jar $(PAPER_JAR) --nogui

# Start server in background
start-bg: setup
	@if [ -f server.pid ] && kill -0 $$(cat server.pid) 2>/dev/null; then \
		echo "Server is already running (PID: $$(cat server.pid))"; \
		exit 1; \
	fi
	@echo "Starting Balbescraft server in background..."
	@nohup java $(JVM_FLAGS) -jar $(PAPER_JAR) --nogui > logs/latest.log 2>&1 & echo $$! > server.pid
	@sleep 2
	@if kill -0 $$(cat server.pid) 2>/dev/null; then \
		echo "Server started with PID: $$(cat server.pid)"; \
		echo "Use 'make logs' to view logs, 'make stop' to stop"; \
	else \
		echo "Server failed to start. Check logs/latest.log"; \
		rm -f server.pid; \
		exit 1; \
	fi

# Stop background server
stop:
	@if [ ! -f server.pid ]; then \
		echo "No server.pid file found. Server may not be running."; \
		exit 0; \
	fi
	@PID=$$(cat server.pid); \
	if kill -0 $$PID 2>/dev/null; then \
		echo "Stopping server (PID: $$PID)..."; \
		kill $$PID; \
		for i in 1 2 3 4 5 6 7 8 9 10; do \
			if ! kill -0 $$PID 2>/dev/null; then \
				echo "Server stopped."; \
				rm -f server.pid; \
				exit 0; \
			fi; \
			sleep 1; \
		done; \
		echo "Server did not stop gracefully, forcing..."; \
		kill -9 $$PID 2>/dev/null || true; \
		rm -f server.pid; \
		echo "Server killed."; \
	else \
		echo "Server is not running (stale PID file)."; \
		rm -f server.pid; \
	fi

# Restart the server
restart: stop
	@sleep 2
	@$(MAKE) start-bg

# Backup world data
backup:
	@echo "Creating backup..."
	@mkdir -p backups
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	if [ -d world ]; then \
		tar -czf backups/world_$$TIMESTAMP.tar.gz world && \
		echo "  Created: backups/world_$$TIMESTAMP.tar.gz"; \
	fi; \
	if [ -d world_nether ]; then \
		tar -czf backups/world_nether_$$TIMESTAMP.tar.gz world_nether && \
		echo "  Created: backups/world_nether_$$TIMESTAMP.tar.gz"; \
	fi; \
	if [ -d world_the_end ]; then \
		tar -czf backups/world_the_end_$$TIMESTAMP.tar.gz world_the_end && \
		echo "  Created: backups/world_the_end_$$TIMESTAMP.tar.gz"; \
	fi
	@echo "Backup complete!"

# Remove generated files (DESTRUCTIVE)
clean:
	@echo "WARNING: This will delete all world data and server files!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	rm -rf world world_nether world_the_end
	rm -rf cache libraries versions
	rm -f eula.txt server.properties usercache.json
	rm -f banned-ips.json banned-players.json ops.json whitelist.json
	rm -f server.pid
	rm -rf logs/*
	@echo "Server files cleaned."

# Show recent logs
logs:
	@if [ -f logs/latest.log ]; then \
		tail -f -n 100 logs/latest.log; \
	else \
		echo "No log file found. Has the server been started?"; \
	fi

# Check server status
status:
	@if [ -f server.pid ] && kill -0 $$(cat server.pid) 2>/dev/null; then \
		echo "Server is RUNNING (PID: $$(cat server.pid))"; \
	else \
		echo "Server is NOT running"; \
		rm -f server.pid 2>/dev/null || true; \
	fi

# Install datapacks from datapacks/ to world/datapacks/
install-datapacks:
	@mkdir -p world/datapacks
	@if [ -d datapacks ] && [ "$$(ls -A datapacks 2>/dev/null | grep -v .gitkeep)" ]; then \
		echo "Installing datapacks..."; \
		for pack in datapacks/*; do \
			if [ -e "$$pack" ] && [ "$$(basename $$pack)" != ".gitkeep" ]; then \
				packname=$$(basename "$$pack"); \
				if [ ! -e "world/datapacks/$$packname" ]; then \
					cp -r "$$pack" world/datapacks/; \
					echo "  Installed: $$packname"; \
				else \
					echo "  Already installed: $$packname"; \
				fi; \
			fi; \
		done; \
	else \
		echo "No datapacks found in datapacks/"; \
	fi

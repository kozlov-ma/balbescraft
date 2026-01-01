FROM eclipse-temurin:21-jre-alpine

# Build arguments
ARG MINECRAFT_VERSION=1.21.11
ARG PAPER_BUILD=latest

# Environment variables
ENV MINECRAFT_VERSION=${MINECRAFT_VERSION}
ENV PAPER_BUILD=${PAPER_BUILD}
ENV MIN_RAM=2G
ENV MAX_RAM=10G
ENV EULA=true

# Install dependencies
# - eudev-libs: fixes "Did not find udev library" warning (runtime library)
# - gosu: for dropping privileges after fixing permissions
RUN apk add --no-cache curl jq bash wget netcat-openbsd eudev-libs gosu

# Create minecraft user and directories
RUN addgroup -g 1000 minecraft && \
    adduser -u 1000 -G minecraft -h /server -D minecraft

WORKDIR /server

# Create necessary directories
RUN mkdir -p /server/plugins \
    /server/config \
    /server/world \
    /server/world_nether \
    /server/world_the_end \
    /server/datapacks \
    /server/logs && \
    chown -R minecraft:minecraft /server

# Download PaperMC
RUN set -e; \
    if [ "$PAPER_BUILD" = "latest" ]; then \
    PAPER_BUILD=$(curl -sf "https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds" | jq -r '.builds[-1].build'); \
    fi && \
    echo "Downloading PaperMC ${MINECRAFT_VERSION} build ${PAPER_BUILD}" && \
    curl -fo /server/paper.jar -L "https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${PAPER_BUILD}/downloads/paper-${MINECRAFT_VERSION}-${PAPER_BUILD}.jar"

# Copy startup script
COPY --chown=minecraft:minecraft scripts/start.sh /server/start.sh
RUN chmod +x /server/start.sh

# Set final permissions
RUN chown -R minecraft:minecraft /server

# Note: Container starts as root to fix bind-mount permissions on Linux hosts,
# then drops to minecraft user via gosu in start.sh

# Expose Minecraft port
EXPOSE 25565

# Volumes for persistent data
VOLUME ["/server/world", "/server/world_nether", "/server/world_the_end", "/server/plugins", "/server/datapacks", "/server/logs"]

# Health check - verify server is responding
HEALTHCHECK --interval=60s --timeout=10s --start-period=180s --retries=3 \
    CMD nc -z localhost 25565 || exit 1

ENTRYPOINT ["/server/start.sh"]

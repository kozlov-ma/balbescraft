# Balbescraft - Dockerized PaperMC Minecraft Server

A fully configured, dockerized PaperMC Minecraft server with vanilla-like experience, offline mode support, and easy configuration.

## Features

- **PaperMC Server 1.21.11** - High-performance Minecraft server
- **Docker Compose** - Easy deployment with `docker compose up`
- **Online Mode** - Premium Minecraft accounts required
- **Whitelist Enabled** - Only whitelisted players can join
- **10GB RAM Default** - Optimized JVM flags (Aikar's flags)
- **Vanilla-like Experience** - Configured per PaperMC docs
- **Configurable** - Seeds, whitelist, world data via Docker volumes
- **Datapack Support** - Easy installation of custom datapacks

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd balbescraft
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your settings
```

### 3. Download Plugins (Optional)

Download the desired plugins and place them in the `plugins/` directory. See [Recommended Plugins](#recommended-plugins) below.

### 4. Start the Server

```bash
docker compose up -d
```

### 5. View Logs

```bash
docker compose logs -f
```

### 6. Stop the Server

```bash
docker compose down
```

## Configuration

### Environment Variables

Edit the `.env` file to customize your server:

| Variable | Default | Description |
|----------|---------|-------------|
| `MIN_RAM` | `2G` | Minimum RAM allocation |
| `MAX_RAM` | `10G` | Maximum RAM allocation |
| `SEED` | (empty) | World seed |
| `WHITELIST_ENABLED` | `false` | Enable whitelist |
| `MOTD` | `A Minecraft Server` | Server message of the day |
| `MAX_PLAYERS` | `20` | Maximum player slots |
| `DIFFICULTY` | `normal` | Game difficulty |
| `GAMEMODE` | `survival` | Default game mode |
| `VIEW_DISTANCE` | `10` | View distance in chunks |
| `SIMULATION_DISTANCE` | `10` | Simulation distance in chunks |

### World Seed

Set the `SEED` variable in your `.env` file:

```bash
SEED=your_custom_seed_here
```

### Whitelist

1. Enable whitelist in `.env`:
   ```bash
   WHITELIST_ENABLED=true
   ```

2. Edit `config/whitelist.json`:
   ```json
   [
     {
       "uuid": "player-uuid-here",
       "name": "PlayerName"
     }
   ]
   ```

   Get player UUIDs from https://mcuuid.net/ or similar services.

### Operators (Admins)

Edit `config/ops.json`:

```json
[
  {
    "uuid": "player-uuid-here",
    "name": "PlayerName",
    "level": 4,
    "bypassesPlayerLimit": true
  }
]
```

## Recommended Plugins

Download these plugins manually and place the `.jar` files in the `plugins/` directory:

### Authentication (Required for Offline Mode)

| Plugin | Description | Download |
|--------|-------------|----------|
| **AuthMe** | Authentication system for offline mode servers | [GitHub](https://github.com/AuthMe/AuthMeReloaded/releases) |

### Skin Restoration

| Plugin | Description | Download |
|--------|-------------|----------|
| **SkinsRestorer** | Restores skins for offline mode players | [SpigotMC](https://www.spigotmc.org/resources/skinsrestorer.2124/) / [GitHub](https://github.com/SkinsRestorer/SkinsRestorer/releases) |

### Chat (Local/Global + Private Messages)

| Plugin | Description | Download |
|--------|-------------|----------|
| **Chatty** | Local chat (configurable range), global chat, PM support | [SpigotMC](https://www.spigotmc.org/resources/chatty-lightweight-universal-chat-plugin.59411/) |
| **EssentialsX + EssentialsXChat** | Alternative: Full suite with /msg, /r, local chat radius | [GitHub](https://github.com/EssentialsX/Essentials/releases) |
| **VentureChat** | Alternative: Channels, local/global chat, PM | [SpigotMC](https://www.spigotmc.org/resources/venturechat.771/) |

### Block Protection & Logging

| Plugin | Description | Download |
|--------|-------------|----------|
| **CoreProtect** | Block logging, rollback, and restore | [GitHub](https://github.com/PlayPro/CoreProtect/releases) / [Modrinth](https://modrinth.com/plugin/coreprotect) |

### Player Actions

| Plugin | Description | Download |
|--------|-------------|----------|
| **GSit** | /sit, /lay, /crawl, /bellyflop commands | [GitHub](https://github.com/Gecolay/GSit/releases) |

### Hiding Player Nametags

You can hide nametags using vanilla commands (no plugin needed):

```
/team add hidden
/team modify hidden nametagVisibility never
/team join hidden @a
```

To automatically add new players, use a repeating command block with:
```
/team join hidden @a[team=]
```

## Volumes & Persistence

| Path | Description |
|------|-------------|
| `world_data` | Main world (Docker volume) |
| `world_nether` | Nether dimension (Docker volume) |
| `world_the_end` | The End dimension (Docker volume) |
| `./config/` | Server configuration files |
| `./plugins/` | Plugin JARs and configurations |
| `./datapacks/` | Custom datapacks |
| `./logs/` | Server logs |

## Installing Datapacks

1. Place your datapack `.zip` files in the `datapacks/` directory
2. Restart the server:
   ```bash
   docker compose restart
   ```

## Server Management

### Console Access

```bash
docker attach balbescraft
```

Press `Ctrl+P` then `Ctrl+Q` to detach without stopping.

### Backup World Data

```bash
# Stop the server first for consistent backup
docker compose stop

# Backup volumes
docker run --rm -v balbescraft_world:/data -v $(pwd)/backups:/backup alpine tar czf /backup/world-$(date +%Y%m%d).tar.gz -C /data .

# Start the server
docker compose start
```

### Update Server

```bash
# Rebuild with latest PaperMC
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Vanilla-Like Experience

The server is configured for a vanilla-like experience following PaperMC recommendations:

- All vanilla game mechanics preserved
- No anti-xray (trust-based server)
- Standard mob spawning and despawn ranges
- Vanilla redstone behavior (`redstone-implementation: VANILLA`)
- Standard hopper mechanics
- All exploits that affect vanilla gameplay are disabled

## Troubleshooting

### Server won't start

Check logs:
```bash
docker compose logs minecraft
```

### Memory issues

Increase RAM in `.env`:
```bash
MAX_RAM=12G
```

Or reduce if your machine has limited memory:
```bash
MIN_RAM=1G
MAX_RAM=2G
```

### Can't connect

1. Verify port 25565 is not blocked by firewall
2. Check server is running: `docker compose ps`
3. Make sure you're using a premium Minecraft account (online-mode is enabled)
4. Make sure your username is in `config/whitelist.json`

### Plugin not loading

1. Verify the plugin JAR exists in `plugins/`
2. Check for errors in `logs/latest.log`
3. Ensure plugin is compatible with Minecraft 1.21.11

## File Structure

```
balbescraft/
├── config/
│   ├── plugin-configs/     # Default plugin configurations
│   ├── server.properties   # Server properties template
│   ├── whitelist.json      # Whitelisted players
│   ├── ops.json            # Server operators
│   ├── banned-players.json # Banned players
│   └── banned-ips.json     # Banned IPs
├── datapacks/              # Custom datapacks
├── logs/                   # Server logs
├── plugins/                # Plugin JARs (download manually)
├── scripts/
│   └── start.sh            # Server startup script
├── .env.example            # Environment template
├── .gitignore              # Git ignore rules
├── docker-compose.yml      # Docker Compose configuration
├── Dockerfile              # Docker image definition
├── Makefile                # Convenience commands
└── README.md               # This file
```

## Make Commands

```bash
make help      # Show available commands
make build     # Build the Docker image
make up        # Start the server
make down      # Stop the server
make logs      # Follow server logs
make console   # Attach to server console
make backup    # Backup world data
make status    # Show container status
```

## License

This project is provided as-is for personal use. Minecraft is a trademark of Mojang Studios. PaperMC and all plugins are property of their respective owners.
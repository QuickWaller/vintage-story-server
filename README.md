# Vintage Story Dedicated Server (Enhanced Fork)

> Docker-based Vintage Story dedicated server with automatic mod management, built-in logging, and Coolify deployment support.

**Special thanks to [quartzar](https://github.com/quartzar) for the original [vintage-story-server](https://github.com/quartzar/vintage-story-server) project.** This fork builds on that excellent foundation with additional features for mod management and automated deployment.

> [!NOTE]
> This is an enhanced fork of [quartzar/vintage-story-server](https://github.com/quartzar/vintage-story-server) with added mod management, comprehensive logging, and deployment automation.

## Features

**Server Management:**
- [x] Easy version configuration (currently 1.22.2)
- [x] Support for both stable and unstable (RC) versions
- [x] Automatic mod downloading and installation from mods.vintagestory.at
- [x] Pre-configured mod list (40+ mods)
- [x] Health checks and container monitoring

**Data & Configuration:**
- [x] Data folder mounted as volume for saves, mods, configs, and logs
- [x] Server configuration files (serverconfig.json, servermagicnumbers.json)
- [x] Log filtering and error monitoring

**Deployment:**
- [x] Docker Compose configuration
- [x] Coolify integration with auto-deployment on git push
- [x] Multi-stage Docker build optimization

**Monitoring:**
- [x] Error and warning filtering via automated log capture
- [x] Startup sequence logging

## Quick Start

### Using Docker Compose (Recommended)

1. Clone or fork this repository
2. Copy `compose.yaml` to your server directory
3. Create a `data` directory: `mkdir data`
4. Update VERSION and MODS as needed in `compose.yaml`
5. Start the server:
   ```bash
   docker compose up -d
   ```
6. Connect to your server at `<your-ip>:42420`

### Custom Configuration

Edit the `compose.yaml` environment variables:

```yaml
environment:
  - TZ=Pacific/Auckland              # Your timezone
  - VERSION=1.22.2                   # Game version
  - MODS=betterruins,watersheds,...  # Comma-separated mod IDs
```

**Current mod list** (from `compose.yaml`):
betterruins, watersheds, mwi, altmapiconrenderercontinued, bloodtrail, medievalarchitecture, falandsknecht, fagothic, fahussar, deathcorpses, favarangian, fadynasties, fajousting, faviking, fatemplar, fagreenwich, bettertraders, healingsprings, offlinefoodnospoil, forestregenmod, tungsten, undergroundmines, terraprety, easybuilding, attributerenderinglibrary, ggbcsrepair, lostandfound, buzzwords, aldiclasses, stepupadvanced, charlottesclothes, xskillsgilded, vsimgui, xlibfork, xskillsfork, em, firewoodtosticks, hardcorewaterevolved, vsextbedrespawn, antiqueharmony, antiqueensemble, realsmoke, opineuponpine, ndltreehollows, canjewelry, roomtools, butchering, automaticforging, spinningwheel, knitting, fishingplus, simpleinfohud, valksfuzzyclouds, curefirewood, rlmoonsun, cartwrightscaravan, nomadtents

See https://mods.vintagestory.at for the full mod catalog and version compatibility.

### Data Directory Structure

After first startup, your `data/` folder will contain:

```
data/
├── Saves/              # World save files
├── Mods/               # Installed mod .zip files (auto-downloaded)
├── ModConfig/          # Mod configuration
├── ModData/            # Mod runtime data
├── Playerdata/         # Player inventory and data
├── Logs/               # Server logs (server-main.log, server-debug.log)
├── Backups/            # Manual backups
├── serverconfig.json   # Server settings
└── servermagicnumbers.json  # Game balance config
```

### Server Configuration

Edit `data/serverconfig.json` to customize:
- Server name and description
- World generation settings
- Player slots and difficulty
- Permissions and admin lists

**Restart the server** after changes: `docker compose restart`

## Requirements

- **Docker** - https://docs.docker.com/get-docker/
- **Hardware** (Official Vintage Story recommendations):
  - **OS**: Windows or Linux
  - **CPU**: 4 Threads recommended (1GHz base + 100MHz per player)
  - **RAM**: 1GB base + 300MB per player
- **Network**: Port 42420 (default, customizable)

## Development & Building

### Building Locally

```bash
# Clone the repository
git clone https://github.com/QuickWaller/vintage-story-server.git
cd vintage-story-server

# Build the Docker image
docker compose build

# Start the server
docker compose up -d
```

### Dockerfile Details

The `Dockerfile`:
- Uses .NET 10 as primary runtime with .NET 8 support
- Downloads the Vintage Story server binary for your VERSION
- Automatically downloads and installs mods from mods.vintagestory.at
- Optimizes Docker layer caching for faster rebuilds
- Runs as non-root gameserver user (security best practice)

## Management

### Viewing Logs

Real-time server logs:
```bash
docker logs -f vintage-story-kjbe9vn1omxtdnjzyiopjlrs
```

Filtered error summary:
```bash
docker exec vintage-story-kjbe9vn1omxtdnjzyiopjlrs \
  cat /data/error-summary.log | head -50
```

### Backups

Create a backup before major updates:
```bash
docker exec vintage-story-kjbe9vn1omxtdnjzyiopjlrs \
  tar -czf /srv/gameserver/data/vs/Backups/backup-$(date +%s).tar.gz \
  /srv/gameserver/data/vs/Saves
```

### Fresh World

To reset and create a fresh world (keeps downloaded mods):
```bash
docker stop vintage-story-kjbe9vn1omxtdnjzyiopjlrs
rm -rf data/Saves data/Playerdata data/ModData data/Cache
docker start vintage-story-kjbe9vn1omxtdnjzyiopjlrs
```

### Client Mods

Vintage Story does not auto-distribute mods to clients — players must install them manually. To download all client-required mod zips locally (for sharing or personal use):

```bash
python download-client-mods.py
```

This reads the `MODS` list from `compose.yaml`, queries the mod API, and downloads all non-server-only mods into `client-mods/`. Safe to re-run; already-present zips are skipped.

### Adding/Removing Mods

1. Update the `MODS` list in `compose.yaml` (comma-separated mod IDs)
2. Commit and push the change
3. Container restarts and mods are auto-downloaded
4. Server will use new mods on next restart

## Deployment via Coolify

This fork is configured for automated Coolify deployment:

1. Fork this repository to your GitHub account
2. Connect your GitHub account in Coolify
3. Create a Docker Compose application pointing to this repo
4. Coolify will auto-detect and rebuild on:
   - Changes to `compose.yaml` (VERSION or MODS)
   - Changes to `Dockerfile`
   - Any other modifications to tracked files

### Coolify Configuration

Set environment variables in Coolify dashboard:
- `VERSION` - Game version (e.g., `1.22.2`)
- `TZ` - Server timezone (e.g., `Pacific/Auckland`)
- `MODS` - Comma-separated mod list

## Troubleshooting

**Server won't start:**
- Check logs: `docker logs vintage-story-...`
- Verify VERSION is valid on https://www.vintagestory.at
- Ensure mods exist and are compatible with your VERSION

**Mods failing to download:**
- Check mod IDs on https://mods.vintagestory.at
- Verify mod VERSION compatibility requirements
- See logs for specific error messages

**Players can't connect:**
- Verify port 42420 is accessible
- Check firewall and port forwarding
- Test: `ping <server-ip>`
- Check network tunnel status (if using playit.gg)

**Permission issues with data directory:**
- Ensure data folder is owned by UID 1000 (gameserver user)
- If deleted manually, reset with: `sudo chown 1000:1000 data && sudo chmod 755 data`

## What's Different from Upstream?

This fork adds:

- **Automatic mod management** - Configure mods in compose.yaml, auto-download on startup
- **Error filtering** - Automated log analysis and error detection
- **Improved documentation** - Comprehensive CLAUDE.md for management via Claude
- **Coolify automation** - Git-to-deployment pipeline
- **Network monitoring** - playit.gg tunnel health checks
- **Better logging** - Server log capture and analysis tools

The upstream repository is at https://github.com/quartzar/vintage-story-server

## Contributing

Found a bug or have a suggestion?
- Open an issue in this repository
- For upstream improvements, see https://github.com/quartzar/vintage-story-server

## License

This project maintains the same license as the original upstream repository.

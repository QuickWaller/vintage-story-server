# Vintage Story Server Management

## Repository Purpose

This is a Docker-based Vintage Story dedicated server with Coolify integration. The repository manages:
- Server configuration (compose.yaml, Dockerfile)
- Game version and mod management
- Documentation and deployment procedures

## My Responsibilities as Claude

When you start a session with this repository, I:
- **Read and understand** this CLAUDE.md file
- **Maintain documentation** - keep it up-to-date, clear, and accurate
- **Manage my memory** - record important patterns, decisions, and context for future sessions
- **Execute management tasks** - use the available skills to manage server and repository state
- **Ask for clarification** - when requirements are unclear, I ask rather than assume
- **Report status** - summarize what changed and what's next after each task

You are here to:
- Direct what needs to happen ("restart the server", "update to version X")
- Clarify goals and constraints
- Provide feedback on approach when needed
- Help debug when something goes wrong

## Environment Configuration (.env)

All user-specific configuration is in `.env`. **Never commit `.env` to git** — it contains credentials and secrets.

### Configuration Variables

**Infrastructure & Access:**
- `SITEHOST_UI_API_KEY` - Coolify API authentication token
- `COOLIFY_API_BASE` - Coolify API base URL
- `SITEHOST_1_SSH_KEY_PATH` - Path to SSH private key
- `SERVER_IP` - Server IP address (192.168.2.151)
- `SSH_USER` - SSH username (claude)
- `SSH_HOST` - SSH hostname (sitehost-1.willscookbook.nz)
- `COOLIFY_APP_ID` - Coolify application identifier
- `SERVER_DATA_PATH` - Full path to server data directory

**Game Server:**
- `TZ` - Server timezone (Pacific/Auckland)
- `VERSION` - Game version (1.22.2)

**Networking:**
- `PLAYIT_AGENT_ID` - playit.gg agent identifier
- `PLAYIT_SECRET_KEY` - playit.gg API authentication secret
- `PLAYIT_PORT` - External port for clients (42420)

**Container Management:**
- `CONTAINER_NAME` - Docker container name
- `PLAYIT_CONTAINER` - playit agent container name

### To Update Configuration

1. Edit `.env` with your values
2. Source the file or use in scripts: `source .env`
3. Reference variables in commands: `ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST ...`
4. Never commit `.env` to git

## Claude's Access & Management

### vintage-story-manage Skill ✅
Manage the Vintage Story server via SSH and Coolify API
- **Server status**: Check container status and health
- **Logs**: View real-time server logs and troubleshoot issues
- **Restart**: Restart the container (triggers mod re-download)
- **SSH access**: Direct shell access via Tailscale (192.168.2.151)
- **Mods**: List installed mods, identify version compatibility
- **Backups**: Create timestamped backups of saves

### vintage-story-repo Skill ✅
Maintain this repository and trigger deployments
- **Version updates**: Update `VERSION` in compose.yaml for game updates
- **Mod management**: Add/remove mods by updating MODS list
- **Deployment**: Commit changes and push to GitHub (Coolify auto-deploys)
- **Coolify API**: Check deployment status, view applications
- **Validation**: Check repository structure, git status, mod compatibility
- **Git operations**: Review history, diff changes, merge upstream updates
- **Upstream sync**: Pull updates from original quartzar/vintage-story-server repo
- **Documentation**: Keep CLAUDE.md and skills documentation current

### vintage-story-network Skill ✅
Monitor and manage the client tunnel infrastructure (playit.gg)
- **Tunnel status**: Check if playit tunnel is healthy and accepting connections
- **Agent status**: Verify playit agent is online and connected
- **Connection monitoring**: Monitor active client connections
- **Tunnel operations**: Create/delete tunnels if needed
- **Diagnostics**: Troubleshoot connectivity issues for players
- **API access**: Full playit.gg API access via secret key

### API & Access Methods (All Configured ✅)

**Coolify API**
- **Base URL**: `$COOLIFY_API_BASE` (from `.env`)
- **Authentication**: Bearer token via `SITEHOST_UI_API_KEY`
- **Status**: ✅ Working (v4.0.0-beta.474)
- **Capabilities**: Applications, servers, deployments, terminal access
- **Limitations**: Cannot read secrets (by design)
- **App ID**: `$COOLIFY_APP_ID`

**SSH Access**
- **Method**: Via Tailscale to `$SERVER_IP`
- **User**: `$SSH_USER`
- **Key**: `$SITEHOST_1_SSH_KEY_PATH`
- **Host**: `$SSH_HOST`
- **Status**: ✅ Working
- **Capabilities**: Full shell access, container management, file access
- **Configured in**: `.env`

**Playit.gg Infrastructure**
- **Agent**: Running in Docker container (playit-ok1p0160sc31ifys5zp6pa1z)
- **Secret Key**: `PLAYIT_SECRET_KEY` in `.env` — used by agent for backend authentication
- **API**: No public REST API. Agent uses internal Rust client library for all tunnel/backend operations
- **Tunnel**: Configured to route clients to sitehost-1.willscookbook.nz on port 42420
- **Status**: ✅ Active and accepting player connections
- **Management**: Tunnel configuration managed through agent, not via public API

### Network Setup
- **Server**: 192.168.2.151 on internal VLAN (Proxmox host)
- **Client tunnel**: playit.gg handles Vintage Story client connections
- **Management SSH**: Via Tailscale to 192.168.2.151 (user: will)
- **Coolify UI**: https://sitehost-ui.willscookbook.nz (cloudflared tunnel, HTTPS with wildcard certs)
- **VPN**: Tailscale provides secure network access across VLANs
- **Certificates**: Wildcard SSL for *.willscookbook.nz installed on both VMs

## Architecture & Access

### Deployment Flow
1. **GitHub Repository**: Fork at https://github.com/QuickWaller/vintage-story-server
   - Upstream: https://github.com/quartzar/vintage-story-server (original)
   - Deployed via GitHub App integration
   
2. **Coolify Management**: https://sitehost-ui.willscookbook.nz
   - REST API for deployments, status, and application management
   - API Token: `SITEHOST_UI_API_KEY` (read, write, deploy access)
   - Documentation: https://coolify.io/docs/api-reference/api/
   - Can trigger deployments by UUID or tag

3. **Server Runtime**: 192.168.2.151:42420
   - SSH access: `root@sitehost-1.willscookbook.nz` (via Coolify tunnel)
   - SSH Key: `~/.ssh/sitehost1`
   - Container: Docker Compose with Vintage Story server

### How It Works
- **Version management**: Edit `VERSION` in compose.yaml
- **Mod management**: Edit `MODS` list in compose.yaml (comma-separated mod IDs)
- **Mod installation**: `check_and_start.sh` downloads mods from https://mods.vintagestory.at/api/mod/{MOD_ID}
- **Deployment**: Push to GitHub → Coolify detects → Rebuilds Docker image → Redeploys
- **Server startup**: Runs `check_and_start.sh` which downloads server binary and mods, then starts server

## Server Management

### SSH Access Pattern

Using environment variables from `.env`:
```bash
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST "docker ps"
```

### Container Operations via SSH

**Status & Logs**
```bash
# Check container status
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST "docker ps | grep $CONTAINER_NAME"

# View logs (last 50 lines)
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST "docker logs $CONTAINER_NAME --tail 50"

# Follow logs in real-time
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST "docker logs $CONTAINER_NAME -f"
```

**Container Control**
```bash
# Restart server (triggers mod download and server startup)
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST "docker restart $CONTAINER_NAME"

# Full compose restart
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST "docker compose restart"
```

**Configured in `.env`:**
- `SITEHOST_1_SSH_KEY_PATH` - SSH private key path
- `SSH_USER` - SSH username (claude)
- `SSH_HOST` - SSH host address
- `CONTAINER_NAME` - Docker container name

### Server Directory Structure

**On `$SERVER_IP`** (Coolify managed):
```
$SERVER_DATA_PATH/
├── docker-compose.yaml      # Pulled from GitHub, updated by Coolify
├── .env
├── README.md
└── data/                    # Mounted volume (Vintage Story server data)
    ├── Saves/              # World save files
    ├── Mods/               # Installed mod .zip files (auto-downloaded)
    ├── ModConfig/          # Mod configurations
    ├── ModData/            # Mod runtime data
    ├── Playerdata/         # Player inventory/data
    ├── Logs/               # Server logs
    ├── Backups/            # Manual backups
    ├── Cache/              # Cached mod unpacking
    ├── serverconfig.json   # Server settings
    └── servermagicnumbers.json # Game balance config
```

**All paths defined in `.env` as:**
- `SERVER_IP` - Server IP address
- `SERVER_DATA_PATH` - Full path to server data directory
- `COOLIFY_APP_ID` - Coolify application ID

**Key files**:
- `serverconfig.json` - Server configuration (restart needed for changes)
- `servermagicnumbers.json` - Game balance settings
- Mods auto-downloaded to `/data/Mods` on startup

### Mods & Version Management

**To change mods or version:**
1. **Edit in repo**: Update `MODS` list or `VERSION` in `compose.yaml`
2. **Or update `.env`**: Set `VERSION` and game configuration
3. **Commit & push**: Push to GitHub (QuickWaller/vintage-story-server)
4. **Coolify redeploys**: Auto-rebuilds Docker image and restarts container
5. **Container startup**: `check_and_start.sh` downloads new binary/mods from their respective sources

**Current mods**: See `compose.yaml` MODS environment variable (comma-separated IDs)

**Version & configuration in `.env`:**
- `VERSION=1.22.2` - Game version to run
- `TZ=Pacific/Auckland` - Server timezone
- Can override in compose.yaml if needed

**Mod compatibility**: Always check version requirements on https://mods.vintagestory.at before adding

### World Creation

To create a **fresh world**:
1. **Stop the server**: `docker stop vintage-story-kjbe9vn1omxtdnjzyiopjlrs`
2. **Delete data folder**: `sudo rm -rf /data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data`
3. **Restore permissions** (gameserver user UID 1000): 
   ```bash
   sudo mkdir -p /data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data
   sudo chown 1000:1000 /data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data
   sudo chmod 755 /data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data
   ```
4. **Restart**: `docker start vintage-story-kjbe9vn1omxtdnjzyiopjlrs`

**Note**: Data folder must be owned by UID 1000 (gameserver user inside container) so it can download mods and create world files

### Server Log Monitoring

A filter script runs every 1 minute on the server to capture errors and startup sequences:

**Script location**: `/usr/local/bin/filter-errors.sh`  
**Output file**: `$SERVER_DATA_PATH/error-summary.log`  
**Update frequency**: Every 1 minute via cron
**Configured in**: `.env` as `SERVER_DATA_PATH`

**What it captures**:
- Full startup sequence (mod loading, initialization, system info)
- All ERROR, CRITICAL, Exception, Failed, crash entries
- Line numbers and timestamps for quick reference
- Organized by log file (server-main.log, server-debug.log)

**Quick health check (interactive):**
```bash
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST \
  "sudo cat $SERVER_DATA_PATH/error-summary.log | head -50"
```

**Force refresh and show latest:**
```bash
ssh -i $SITEHOST_1_SSH_KEY_PATH $SSH_USER@$SSH_HOST \
  "sudo /usr/local/bin/filter-errors.sh && cat $SERVER_DATA_PATH/error-summary.log"
```

For automated/scheduled monitoring, use the `server-log-monitor` skill instead.

### Backups

Backups can be created manually via SSH:
```bash
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz \
  "tar -czf /srv/gameserver/data/vs/Backups/backup-$(date +%s).tar.gz /srv/gameserver/data/vs/Saves"
```

## Repository Structure

```
vintage-story-server/
├── compose.yaml          # Docker Compose - VERSION and MODS config
├── Dockerfile            # Multi-stage build: .NET 8/10, downloads and runs scripts
├── README.md             # User-facing documentation
├── CLAUDE.md             # This file - Claude's management guide
├── .env                  # Credentials (gitignored)
│   ├── SITEHOST_UI_API_KEY        # Coolify API token
│   └── SITEHOST_1_SSH_KEY_PATH    # SSH key path for server access
├── scripts/              # Container entry point scripts
│   ├── download_server.sh          # Downloads Vintage Story binary
│   └── check_and_start.sh          # Version check, mod download, server startup
├── skills/               # Skill documentation
│   ├── vintage-story-manage.md     # Server management operations
│   ├── vintage-story-repo.md       # Repository maintenance
│   └── vintage-story-network.md    # Network/tunnel monitoring (playit.gg)
├── .github/              # GitHub Actions workflows
└── data/                 # Server data volume (gitignored)
    ├── Saves/            # Game world saves
    ├── Mods/             # Installed mods (auto-downloaded)
    ├── Logs/             # Server logs
    └── Backups/          # Manual backups
```

### How It Works

1. **Local changes** → `compose.yaml` (VERSION, MODS)
2. **Commit to GitHub** → QuickWaller/vintage-story-server fork
3. **Coolify detects push** → Rebuilds Docker image
4. **Docker build** → Copies scripts, sets up .NET runtimes
5. **Container starts** → `check_and_start.sh` runs:
   - Checks if VERSION changed, downloads server binary if needed
   - Downloads each mod from mods.vintagestory.at API
   - Starts Vintage Story server with `/srv/gameserver/data/vs` data path
6. **playit.gg tunnel** → Connects clients to server (port 42420)
7. **Players connect** → Via playit.gg tunnel to sitehost-1.willscookbook.nz

### Maintenance Workflow

**Update Game Version**
1. Update `VERSION=X.Y.Z` in `compose.yaml`
2. Commit with message: `Update game version to X.Y.Z`
3. Push to GitHub → Coolify rebuilds → Container restarts
4. Server downloads new binary on startup

**Add a Mod**
1. Find mod ID on https://mods.vintagestory.at (e.g., "betterarcheology")
2. Add to `MODS` list in `compose.yaml` (comma-separated)
3. Commit: `Add mod: betterarcheology`
4. Push → Coolify rebuilds → Server downloads mod on restart
5. Check version compatibility before adding

**Remove a Mod**
1. Remove from `MODS` list in `compose.yaml`
2. Commit: `Remove mod: walkingstick`
3. Push → Coolify rebuilds → Old mod not downloaded on restart

**Update Dockerfile/Scripts**
1. Modify `Dockerfile` or scripts in `scripts/`
2. Commit changes
3. Push → Coolify rebuilds with new image

## Claude Access & Automation

Claude can:
- SSH into the server to manage containers, check logs, and update configuration
- Use Coolify API to trigger deployments (when UI is operational)
- Update mods and game version
- Manage backups
- Commit changes to git
- Update documentation

### Credentials
- SSH: `~/.ssh/sitehost1`
- Coolify API: `SITEHOST_UI_API_KEY` in `.env`

## Common Tasks & Examples

### "Check the server status"
→ Uses `vintage-story-manage`
- Runs: `docker ps | grep vs-server` via SSH
- Returns: Container state, uptime, health

### "Show me recent logs"
→ Uses `vintage-story-manage`
- Runs: `docker logs vs-server --tail 50` via SSH
- Returns: Last 50 lines of server output

### "Update to version 1.23.0"
→ Uses `vintage-story-repo`
1. Edits `compose.yaml`: `VERSION=1.23.0`
2. Commits: `Update game version to 1.23.0`
3. Pushes to GitHub → Coolify rebuilds → Server downloads new binary

### "Add the betterarcheology mod"
→ Uses `vintage-story-repo`
1. Adds to `MODS` list in `compose.yaml`
2. Commits: `Add mod: betterarcheology`
3. Pushes → Coolify rebuilds → Server downloads mod on next restart

### "Remove the walkingstick mod"
→ Uses `vintage-story-repo`
1. Removes from `MODS` list
2. Commits: `Remove mod: walkingstick`
3. Pushes → Server won't download it on restart

### "Check if clients can connect"
→ Uses `vintage-story-network` (playit.gg)
- Checks tunnel status
- Verifies agent is online
- Reports connection health

### "Create a backup"
→ Uses `vintage-story-manage`
- Runs: `tar -czf backup-[timestamp].tar.gz /srv/gameserver/data/vs/Saves`
- Stores in: `/srv/gameserver/data/vs/Backups/`

### "Check what mods are installed"
→ Uses `vintage-story-repo`
- Reads: `MODS` list from `compose.yaml`
- Returns: All active mods with versions

## Setup Status

### Complete ✅
- **Coolify API** - Authenticated and operational
- **SSH Access** - Via Tailscale using `claude` user with SSH key auth (passwordless)
- **Playit.gg Integration** - Secret key configured and ready (integrating into compose tomorrow)
- **HTTPS/TLS** - Wildcard certificates installed on both VMs
- **Three Management Skills** - vintage-story-manage, vintage-story-repo, vintage-story-network all functional
- **Git Repository** - QuickWaller/vintage-story-server fork deployed via Coolify
- **Environment Configuration** - All user-specific config moved to `.env` (never published)
- **Documentation** - README, CLAUDE.md, and skills docs comprehensive and current
- **Server** - Running 1.22.2 (latest stable) with fresh world, 40+ mods

### Infrastructure
- Cloudflare tunnels: sitehost-ui.willscookbook.nz (Coolify), cloudflared agent (playit.gg)
- Tailscale VPN: Connects across VLAN boundaries for secure access
- Deployments: GitHub → Coolify (auto-rebuild on push)
- Mods: Auto-downloaded from mods.vintagestory.at on container startup
- Error monitoring: filter-errors.sh runs every 1 minute on server

### Tomorrow's Priorities
1. Eliminate all server startup errors
2. Integrate playit.gg into docker-compose for standalone deployment
3. Set up automated cron jobs (daily backups, log rotation, weekly stats)

## Working Relationship

**What you can expect from me:**
- When you ask "what's the server status?", I use `vintage-story-manage` to check
- When you ask "remove mod X", I update compose.yaml, commit, and restart
- I keep this CLAUDE.md and my memory up-to-date as the repo evolves
- I explain what I'm doing and ask before destructive operations
- I report the outcome of each action clearly

**How to work with me:**
- Use natural language ("restart the server", "add the betterarcheology mod")
- I'll invoke the appropriate skill and execute the action
- No need to specify exact commands - just say what needs doing
- I'll track decisions and patterns in memory for consistency across sessions

## Important Notes & Security

### Credentials Management
- **`.env` file** - Contains API keys and SSH paths (NEVER commit, gitignored)
- **playit secret key** - Grants full tunnel control (keep private)
- **Coolify API token** - Can trigger deployments (limited permissions)
- **SSH private key** - Local filesystem access to server (secure)

### Deployment Safety
- Changes flow through: Git commit → GitHub push → Coolify detection → Docker rebuild → Server restart
- This audit trail prevents accidental changes
- Always verify `compose.yaml` changes before pushing
- Test mod compatibility before adding to MODS list

### Data Management
- **Saves are valuable** - Located in `/srv/gameserver/data/vs/Saves`
- **Mods auto-download** - No manual copying needed, download happens on container startup
- **Backups** - Create before major updates or version changes
- **Logs** - Available at `/srv/gameserver/data/vs/Logs` for debugging

### Upstream Repository
- Original: https://github.com/quartzar/vintage-story-server
- Your fork: https://github.com/QuickWaller/vintage-story-server (with mod scripts)
- Can pull upstream changes to stay updated with improvements

### Mod Compatibility
- **Always check version compatibility** on https://mods.vintagestory.at
- Mods must match your `VERSION` setting
- Check the mod's "Files" table for version requirements
- Incompatible mods will cause server startup failures

### Documentation
- This CLAUDE.md is the source of truth for my responsibilities and operations
- I maintain it as the repo evolves
- Skills documentation in `skills/` directory describes what I can do

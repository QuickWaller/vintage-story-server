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
- **Management SSH**: Via Tailscale to 192.168.2.151 (user: claude)
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
   - SSH access: `claude@192.168.2.151` (via Tailscale, requires `sudo` for docker commands)
   - SSH Key: `$SITEHOST_1_SSH_KEY_PATH` from `.env`
   - Container: Docker Compose with Vintage Story server

### How It Works
- **Version management**: Edit `VERSION` in compose.yaml
- **Mod management**: Edit `MODS` list in compose.yaml (comma-separated mod IDs)
- **Mod installation**: `check_and_start.sh` downloads mods from https://mods.vintagestory.at/api/mod/{MOD_ID}
- **Deployment**: Push to GitHub → Coolify detects → Rebuilds Docker image → Redeploys
- **Server startup**: Runs `check_and_start.sh` which downloads server binary and mods, then starts server

## Server Management

### SSH Access Pattern

**Always use `SERVER_IP` (192.168.2.151) directly** — `SSH_HOST` (`sitehost-1.willscookbook.nz`) is unreachable. The `claude` user requires `sudo` for all docker commands.

```bash
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "sudo docker ps"
```

### Container Operations via SSH

**Status & Logs**
```bash
# Check container status
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "sudo docker ps | grep $CONTAINER_NAME"

# View logs (last 50 lines)
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "sudo docker logs $CONTAINER_NAME --tail 50"

# View startup errors only
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "sudo docker logs $CONTAINER_NAME 2>&1 | grep '\[Server Error\]'"
```

**Container Control**
```bash
# Stop server
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "sudo docker stop $CONTAINER_NAME"

# Start server
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "sudo docker start $CONTAINER_NAME"

# Restart server
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "sudo docker restart $CONTAINER_NAME"
```

### Server Console Commands

To send commands to the live server console (whitelist, serverconfig, etc.) use tmux + docker attach:

```bash
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "
tmux new-session -d -s vs 'sudo docker attach --sig-proxy=false $CONTAINER_NAME'
sleep 2
tmux send-keys -t vs '/whitelist add PlayerName' Enter
sleep 2
tmux capture-pane -t vs -p
tmux kill-session -t vs
"
```

**Notes:**
- `--sig-proxy=false` ensures killing the tmux session won't stop the container
- Works for any server command: `/whitelist add/remove`, `/serverconfig`, `/op`, etc.
- Whitelist entries stored in `$SERVER_DATA_PATH/Playerdata/playerswhitelisted.json`

### Server Directory Structure

**On `$SERVER_IP`** (Coolify managed):
```
$SERVER_DATA_PATH/               # = /data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data
├── Saves/                       # World save files
├── Mods/                        # Installed mod .zip files (auto-downloaded)
├── ModConfig/                   # Mod configurations
├── ModData/                     # Mod runtime data
├── Playerdata/                  # Player inventory/data
├── Logs/                        # Server logs
├── Backups/                     # Backup archives
├── BackupSaves/                 # Secondary backup location
├── Cache/                       # Cached mod unpacking
├── WorldEdit/                   # WorldEdit data
├── Macros/                      # Server macros
├── serverconfig.json            # Server settings (world gen, roles, startup commands)
├── servermagicnumbers.json      # Game balance config
└── error-summary.log            # Filtered error log (updated every 1 min)
```

**Note**: `SERVER_DATA_PATH` points directly to the game data root — there is no nested `data/` subfolder. All SSH paths use `$SERVER_DATA_PATH/Saves`, `$SERVER_DATA_PATH/Logs`, etc.

**Key files**:
- `serverconfig.json` - Server configuration (restart needed for changes); edit via `python3` + `sudo cp` pattern (see below)
- `servermagicnumbers.json` - Game balance settings
- Mods auto-downloaded to `$SERVER_DATA_PATH/Mods` on startup

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

**Fresh world keeping mods** (preferred — faster, no redeploy needed):
```bash
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "
sudo docker stop $CONTAINER_NAME
sudo rm -rf $SERVER_DATA_PATH/Saves $SERVER_DATA_PATH/Playerdata $SERVER_DATA_PATH/ModData $SERVER_DATA_PATH/Cache
sudo docker start $CONTAINER_NAME
"
```
Preserves the already-downloaded Mods folder so startup is fast. Also delete `$SERVER_DATA_PATH/ModConfig/TerraPrety.json` if resetting world gen config.

**Full data wipe** (only if also clearing mods — redeploy required):
```bash
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "
sudo docker stop $CONTAINER_NAME
sudo rm -rf $SERVER_DATA_PATH
sudo mkdir -p $SERVER_DATA_PATH
sudo chown 1000:1000 $SERVER_DATA_PATH
sudo chmod 755 $SERVER_DATA_PATH
"
```
Then trigger a Coolify redeploy so the container re-downloads mods on startup.

**Note**: Data folder must be owned by UID 1000 (gameserver user inside container) so it can write world files.

### World Generation Settings

Current world is configured with Terra Prety recommended settings (set in `serverconfig.json`):

| Setting | Value | Where |
|---------|-------|-------|
| `MapSizeY` | `384` | root + `WorldConfig.MapSizeY` |
| `landformScale` | `3.0` (300%) | `WorldConfig.WorldConfiguration` |
| `playerMoveSpeed` | `1.5` (slightly faster) | `WorldConfig.WorldConfiguration` |
| `noLiquidSourceTransport` | `true` | `StartupCommands` (runs `/worldconfig` on startup) |

**Important**: `WorldConfig.WorldConfiguration` settings only apply at world creation. To change them on an existing world, use `/worldconfig <key> <value>` via the server console. `StartupCommands` re-applies settings on every startup.

### Editing serverconfig.json

The file is owned by `will` on the host. The `claude` user can read it but not write directly. Use this pattern:

```bash
# 1. Modify as claude (no sudo needed for python3)
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "python3 -c \"
import json
path = '$SERVER_DATA_PATH/serverconfig.json'
with open(path) as f: config = json.load(f)
# ... make changes ...
with open('/home/claude/serverconfig_new.json', 'w') as f: json.dump(config, f, indent=2)
\""

# 2. Copy into place (sudo cp is allowed)
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 \
  "sudo cp /home/claude/serverconfig_new.json $SERVER_DATA_PATH/serverconfig.json"
```

**Claude's sudo allowlist** (NOPASSWD): `docker`, `rm`, `chmod`, `chown`, `mkdir`, `tar`, `cp`, `wget`, `cat`, `ls`  
`python3`, `tee`, and other commands require a password — use the python3 + sudo cp pattern above.

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

### Cron Jobs (Container-Internal)

Scheduled tasks run inside the container as the `gameserver` user. The crontab is installed by `entrypoint.sh` at startup from `scripts/crontab`.

| Schedule | Script | Purpose |
|----------|--------|---------|
| 3am daily (NZST) | `backup.sh` | Tar Saves dir with timestamp, keep last 7 |
| 4am daily (NZST) | `log-rotate.sh` | Gzip logs >1 day old, delete compressed >14 days |

To check cron is running inside the container:
```bash
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 \
  "sudo docker exec $CONTAINER_NAME pgrep cron && echo 'cron running'"
```

To manually trigger a backup:
```bash
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 \
  "sudo docker exec $CONTAINER_NAME /srv/gameserver/vintagestory/backup.sh"
```

### Backups

Automated backups run daily at 3am (Pacific/Auckland) via the container-internal cron job (`scripts/backup.sh`). Keeps last 7 backups. Logs to `$SERVER_DATA_PATH/Backups/backup.log`.

Manual backup via SSH:
```bash
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 \
  "sudo docker exec $CONTAINER_NAME /srv/gameserver/vintagestory/backup.sh"
```

## Repository Structure

```
vintage-story-server/
├── compose.yaml                # Docker Compose - VERSION and MODS config
├── Dockerfile                  # Multi-stage build: .NET 8/10, downloads and runs scripts
├── README.md                   # User-facing documentation
├── CLAUDE.md                   # This file - Claude's management guide
├── download-client-mods.py     # Script: downloads client-required mods to client-mods/
├── .env                        # Credentials (gitignored)
│   ├── SITEHOST_UI_API_KEY        # Coolify API token
│   └── SITEHOST_1_SSH_KEY_PATH    # SSH key path for server access
├── client-mods/                # Client mod zips (gitignored *.zip, tracked via .gitkeep)
├── scripts/                    # Container entry point scripts
│   ├── entrypoint.sh               # Root entrypoint: starts cron daemon, su's to gameserver
│   ├── check_and_start.sh          # Version check, mod download (releases[0]), server startup
│   ├── download_server.sh          # Downloads Vintage Story binary
│   ├── backup.sh                   # Timestamped Saves backup, keeps last 7
│   ├── log-rotate.sh               # Gzip old logs, purge >14 days
│   └── crontab                     # Cron schedule (3am backup, 4am log rotation)
├── skills/                     # Skill documentation
│   ├── vintage-story-manage.md     # Server management operations
│   ├── vintage-story-repo.md       # Repository maintenance
│   └── vintage-story-network.md    # Network/tunnel monitoring (playit.gg)
├── .github/                    # GitHub Actions workflows
└── data/                       # Server data volume (gitignored)
    ├── Saves/                  # Game world saves
    ├── Mods/                   # Installed mods (auto-downloaded)
    ├── Logs/                   # Server logs
    └── Backups/                # Manual backups
```

### How It Works

1. **Local changes** → `compose.yaml` (VERSION, MODS)
2. **Commit to GitHub** → QuickWaller/vintage-story-server fork
3. **Coolify detects push** → Rebuilds Docker image
4. **Docker build** → Copies scripts, sets up .NET runtimes
5. **Container starts** → `entrypoint.sh` runs as root:
   - Installs gameserver's crontab (`backup.sh` at 3am, `log-rotate.sh` at 4am)
   - Starts cron daemon
   - `su`s to gameserver and runs `check_and_start.sh`
6. **`check_and_start.sh` runs:**
   - Checks if VERSION changed, downloads server binary if needed
   - Downloads each mod from mods.vintagestory.at API
   - Starts Vintage Story server with `/srv/gameserver/data/vs` data path
7. **playit.gg tunnel** → Connects clients to server (port 42420)
8. **Players connect** → Via playit.gg tunnel to sitehost-1.willscookbook.nz

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
- SSH: `$SITEHOST_1_SSH_KEY_PATH` from `.env` (resolves to `~/.ssh/sitehost1`)
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
- **SSH Access** - Via Tailscale to 192.168.2.151 using `claude` user with SSH key auth (passwordless, sudo for docker)
- **Playit.gg Integration** - Agent running, tunnel active on port 42420
- **HTTPS/TLS** - Wildcard certificates installed on both VMs
- **Three Management Skills** - vintage-story-manage, vintage-story-repo, vintage-story-network all functional
- **Git Repository** - QuickWaller/vintage-story-server fork deployed via Coolify
- **Environment Configuration** - All user-specific config moved to `.env` (never published)
- **Documentation** - README, CLAUDE.md, and skills docs comprehensive and current
- **Server** - Running 1.22.2 (latest stable) with fresh world (Terra Prety, 57 mods)
- **Container Cron Jobs** - Daily backups (3am) and log rotation (4am) running inside container
- **Startup errors resolved** - Clean startup on 1.22.2 with current mod set
- **World gen configured** - MapSizeY 384, landformScale 3.0, playerMoveSpeed 1.5, noLiquidSourceTransport
- **Client mods script** - `download-client-mods.py` downloads all client-required mod zips locally

### Infrastructure
- Cloudflare tunnels: sitehost-ui.willscookbook.nz (Coolify), cloudflared agent (playit.gg)
- Tailscale VPN: Connects across VLAN boundaries for secure access
- Deployments: GitHub → Coolify (auto-rebuild on push)
- Mods: Auto-downloaded from mods.vintagestory.at on container startup
- Cron: backup.sh + log-rotate.sh run daily inside container via entrypoint.sh

### Known Issues / Pending Fixes
1. **OGG client crash** — `antiqueharmony` and `antiqueensemble` cause `OutOfMemoryException` in OGG decoder; remove both mods when ready
2. **UDP tunnel** — playit.gg tunnel appears TCP-only; VS falls back to TCP for position updates causing slow loading; investigate enabling UDP on the tunnel

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

### Client Mods

VS does **not** auto-distribute mods to clients. Players must install mods manually.

- **Both-sided mods** — required on client to connect (crash on join if missing)
- **Client-only mods** — optional, install for visual/UI improvements

**To download all client-required mods locally:**
```bash
python download-client-mods.py
```
Downloads non-server-only mods from the MODS list into `client-mods/` (uses `releases[0]`, same as the server). Safe to re-run — skips already-present zips. Copy the zips into your VS `Mods` folder.

**Whitelisting players:**
```bash
# Via tmux + docker attach
ssh -i ~/.ssh/sitehost1 claude@192.168.2.151 "
tmux new-session -d -s vs 'sudo docker attach --sig-proxy=false $CONTAINER_NAME'
sleep 2
tmux send-keys -t vs '/whitelist add PlayerName' Enter
sleep 2
tmux capture-pane -t vs -p
tmux kill-session -t vs
"
```

### Documentation
- This CLAUDE.md is the source of truth for my responsibilities and operations
- I maintain it as the repo evolves
- Skills documentation in `skills/` directory describes what I can do

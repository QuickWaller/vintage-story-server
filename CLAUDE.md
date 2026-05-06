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

## Claude's Access & Management

### vintage-story-manage Skill
Manage the Vintage Story server via SSH and Coolify API
- **Server status**: Check container status and health
- **Logs**: View real-time server logs and troubleshoot issues
- **Restart**: Restart the container (triggers mod re-download)
- **SSH access**: Direct shell access as root via sitehost-1.willscookbook.nz
- **Mods**: List installed mods, identify version compatibility
- **Backups**: Create timestamped backups of saves

### vintage-story-repo Skill
Maintain this repository and trigger deployments
- **Version updates**: Update `VERSION` in compose.yaml for game updates
- **Mod management**: Add/remove mods by updating MODS list
- **Deployment**: Commit changes and trigger Coolify rebuild/deploy via API
- **Validation**: Check repository structure, git status, mod compatibility
- **Git operations**: Review history, diff changes, merge upstream updates
- **Documentation**: Keep CLAUDE.md and skills documentation current

### Coolify API Access
- **Base URL**: https://sitehost-ui.willscookbook.nz/api/v1
- **Authentication**: Token via `SITEHOST_UI_API_KEY` 
- **Capabilities**: Trigger deployments, check application status, view logs
- **Limitations**: Cannot read secrets (by design)

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
```bash
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz "docker ps"
```

### Container Operations via SSH

**Status & Logs**
```bash
# Check container status
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz "docker ps | grep vs-server"

# View logs (last 50 lines)
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz "docker logs vs-server --tail 50"

# Follow logs in real-time
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz "docker logs vs-server -f"
```

**Container Control**
```bash
# Restart server (triggers mod download and server startup)
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz "docker restart vs-server"

# Full compose restart
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz "cd /srv/gameserver && docker compose restart"
```

### Server Data Locations
- Server config: `/srv/gameserver/data/vs/serverconfig.json`
- Mods directory: `/srv/gameserver/data/vs/Mods` (auto-downloaded on startup)
- Saves: `/srv/gameserver/data/vs/Saves`
- Logs: `/srv/gameserver/data/vs/Logs`

### Mods Management

Mods are installed automatically from the `MODS` environment variable during container startup.

**To add/remove mods:**
1. Update `MODS` in `compose.yaml` (comma-separated mod IDs from mods.vintagestory.at)
2. Commit the change to git
3. Push to GitHub → Coolify rebuilds and redeploys → Container restarts with new mods

**Mod ID lookup**: Visit https://mods.vintagestory.at and check the mod's mod ID (e.g., "betterarcheology")

**Current mods**: See `compose.yaml` line 18

### Backups

Backups can be created manually via SSH:
```bash
ssh -i ~/.ssh/sitehost1 root@sitehost-1.willscookbook.nz \
  "tar -czf /srv/gameserver/data/vs/Backups/backup-$(date +%s).tar.gz /srv/gameserver/data/vs/Saves"
```

## Repository Management

### Structure
```
vintage-story-server/
├── compose.yaml          # Docker Compose config (local dev)
├── Dockerfile           # Server image definition
├── README.md            # User documentation
├── CLAUDE.md            # This file
├── .env                 # Credentials (gitignored)
├── scripts/             # Management scripts
│   ├── server-manage.sh # Server management tasks
│   └── repo-maintain.sh # Repository maintenance
└── data/                # Server data volume (gitignored)
```

### Maintenance Tasks

**Update Game Version**
1. Update `VERSION` in `compose.yaml`
2. Restart container: `docker compose restart`
3. Commit changes

**Add/Remove Mods**
1. Update `MODS` list in `compose.yaml`
2. Commit with reason
3. Restart container

**Update Dockerfile**
1. Modify `Dockerfile`
2. Rebuild: `docker compose build --no-cache`
3. Restart: `docker compose up -d`

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

## Common Tasks

### Check Server Status
```bash
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "docker ps | grep vs-server"
```

### View Recent Logs
```bash
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "docker logs vs-server --tail 50"
```

### Remove a Mod
1. Edit `compose.yaml` - remove mod from `MODS` list
2. Commit: `git commit -am "Remove [mod-name]"`
3. Restart: SSH and run `docker compose restart`

### Update Game Version
1. Edit `compose.yaml` - update `VERSION` value
2. Commit with new version number
3. Restart: SSH and run `docker compose restart`

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

## Important Notes

- The `.env` file contains credentials (gitignored) - never commit it
- Server data persists in the mounted `./data` volume
- Always commit changes to `compose.yaml` for version control
- Backups should be created before major updates
- Documentation is a living document - I'll keep it current

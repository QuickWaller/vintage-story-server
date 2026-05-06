# Vintage Story Server Management

This project provides a Docker-based Vintage Story dedicated server with automated management capabilities. Claude has full access to manage both the server and this repository.

## Access & Infrastructure

### Server Details
- **Host**: will@192.168.2.151 (via SSH)
- **SSH Key**: `~/.ssh/sitehost1`
- **Coolify API**: https://sitehost-ui.willscookbook.nz
- **API Key**: Stored in `.env` as `SITEHOST_UI_API_KEY`
- **Game Version**: 1.22.0 (configured in `compose.yaml`)
- **Port**: 42420

### Network Setup
- Server on VLAN 192.168.2.x (Proxmox host)
- Coolify exposed via public domain (sitehost-ui.willscookbook.nz)
- Tailscale VPN available for inter-network access

## Server Management

### Available Commands

**Status & Logs**
```bash
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "docker ps"
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "docker logs vs-server"
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "docker logs vs-server -f"  # follow logs
```

**Container Control**
```bash
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "cd /srv/gameserver && docker compose restart"
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "cd /srv/gameserver && docker compose stop"
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "cd /srv/gameserver && docker compose start"
```

**Game Server Commands**
- Server config: `/srv/gameserver/data/vs/serverconfig.json`
- Mods directory: `/srv/gameserver/data/vs/Mods`
- Saves: `/srv/gameserver/data/vs/Saves`
- Logs: `/srv/gameserver/data/vs/Logs`

### Mods Management

Mods are configured in `compose.yaml` via the `MODS` environment variable (comma-separated list).

**To add/remove mods:**
1. Update `compose.yaml` with new mod list
2. Restart container: `docker compose restart`

**Current mods**: See `compose.yaml` line 18

### Backups

Backup structure:
- Saves: `/srv/gameserver/data/vs/Saves/`
- Backups: `/srv/gameserver/data/vs/Backups/`

Manual backup:
```bash
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 "tar -czf /srv/gameserver/data/vs/Backups/backup-$(date +%s).tar.gz /srv/gameserver/data/vs/Saves"
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

## Notes
- The `.env` file contains credentials and is gitignored
- Server data persists in the mounted `./data` volume
- Always commit changes to `compose.yaml` for version control
- Backups should be created before major updates

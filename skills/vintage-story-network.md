# vintage-story-network

Monitor and manage the Vintage Story server's network infrastructure via playit.gg tunnels. Diagnose client connectivity issues and verify the tunnel is operational.

## Parameters

- **action** (required): The operation to perform
  - `status` - Check tunnel and agent health
  - `clients` - List active client connections
  - `agent-info` - Show playit agent status and details
  - `tunnel-list` - List all configured tunnels
  - `diagnostics` - Full network connectivity check

## Examples

- "Is the playit tunnel working?"
- "Can players connect to the server?"
- "How many clients are connected?"
- "Check the network status"
- "Run network diagnostics"

## Technical Details

### Deployment
- **Service**: playit.gg (tunneling infrastructure)
- **Agent**: Running on 192.168.2.151
- **Tunnel endpoint**: sitehost-1.willscookbook.nz
- **Game port**: 42420 (Vintage Story default)
- **Connection**: Cloudflared tunnel from server to playit.gg

### Credentials & Architecture
- **Secret Key**: `PLAYIT_SECRET_KEY` in `.env` — used by the playit agent for authentication
- **API**: No public REST API. The playit agent uses an internal Rust client library to communicate with playit.gg backend
- **Agent Role**: The Docker container runs the playit agent, which manages tunnel configuration, registration, and connection monitoring
- **Tunnel Management**: All tunnel operations happen through the agent's internal client library, not via public API endpoints

### Troubleshooting
- **Tunnel down**: Check playit.gg status page, restart agent
- **No clients connecting**: Verify server is running, check tunnel health
- **Connection drops**: Check internet stability, review playit logs
- **Agent offline**: SSH to server and check playit agent process

### Agent & Tunnel Management

**No Public REST API**: playit.gg does not expose a public REST API for tunnel management. The agent uses an internal Rust client library for backend communication.

**Tunnel Configuration**: 
- Managed through the playit agent running in Docker container
- Configuration persists through agent restarts
- Changes require agent reconfiguration or restart

**To modify tunnel settings:**
1. Check playit.gg web dashboard (if available)
2. Contact playit.gg support for advanced configuration
3. Restart the agent container to apply changes: `docker restart playit-{agent-id}`

### Related Documentation
- playit.gg Agent Docs: https://deepwiki.com/playit-cloud/playit-agent
- Tunnel API: https://deepwiki.com/playit-cloud/playit-agent/3.4-api-client
- Main: https://playit.gg/

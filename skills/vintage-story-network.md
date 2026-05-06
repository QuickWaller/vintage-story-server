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

### Credentials
- **Secret Key**: `PLAYIT_SECRET_KEY` in `.env`
- **API Base**: https://api.playit.gg/api/v1 (typical, configured per instance)
- **Authentication**: Bearer token via secret key

### Troubleshooting
- **Tunnel down**: Check playit.gg status page, restart agent
- **No clients connecting**: Verify server is running, check tunnel health
- **Connection drops**: Check internet stability, review playit logs
- **Agent offline**: SSH to server and check playit agent process

### Related Documentation
- playit.gg Docs: https://deepwiki.com/playit-cloud/playit-agent
- Tunnel API: https://deepwiki.com/playit-cloud/playit-agent/3.4-api-client

# vintage-story-manage

Manage the Vintage Story dedicated server. Perform operations like checking status, viewing logs, restarting the server, managing mods, and creating backups.

## Parameters

- **action** (required): The operation to perform
  - `status` - Check if server is running
  - `logs` - View recent server logs
  - `logs-follow` - Follow server logs in real-time
  - `restart` - Restart the server
  - `stop` - Stop the server
  - `start` - Start the server
  - `backup` - Create a timestamped backup of saves
  - `mods-list` - List all active mods
  - `add-mod <name>` - Add a mod (requires name)
  - `remove-mod <name>` - Remove a mod (requires name)
  - `config` - Show server configuration

## Examples

- "Check the server status"
- "Show me the last 100 logs"
- "Restart the server"
- "Add the betterarcheology mod"
- "Remove the walkingstick mod"
- "Create a backup"
- "What mods are currently active?"

## Notes

- Server is located at 192.168.2.151
- SSH access via ~/.ssh/sitehost1
- Changes to mods require server restart
- Backups are timestamped and stored on the server

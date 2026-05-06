# haiku-console-monitor

Monitor Vintage Story server logs for errors and issues after startup or configuration changes. Spawns a lightweight Haiku agent to quickly analyze logs and report problems.

## Parameters

- **context** (optional): What triggered the check
  - `startup` - Server just started, look for startup/initialization errors
  - `config-change` - Configuration was modified, check if changes applied correctly
  - `general` - General health check (default)

## Examples

- "Check the server logs for errors"
- "After restarting, analyze the logs"
- "Did the mod changes apply correctly? Check the logs"
- "Show me any server errors from the last startup"

## What It Does

1. **SSH** to 192.168.2.151 and reads:
   - `/data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data/Logs/server-main.log`
   - `/data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data/Logs/server-debug.log`

2. **Searches** for:
   - ERROR, CRITICAL, Exception
   - Failed connections or mod loads
   - Version/compatibility issues
   - Crashes or crashes

3. **Outputs**:
   - ✅ `Server healthy` (no errors)
   - ⚠️ `Warnings found:` with list
   - ❌ `Critical errors:` with details, timestamps, and line numbers

## When to Use

- After making changes (version, mods, config)
- After server restart
- Troubleshooting connectivity issues
- Verifying deployments applied correctly

## Notes

- Fast analysis (Haiku model) - good for quick health checks
- Returns structured output with timestamps
- Focuses on the most recent errors first

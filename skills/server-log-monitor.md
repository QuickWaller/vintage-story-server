# server-log-monitor

Monitor Vintage Story server logs for errors and issues after startup or configuration changes. Analyzes pre-filtered logs and reports problems.

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

## How It Works

**Server-side filtering** (pre-processing):
- `/usr/local/bin/filter-errors.sh` runs every 1 minute via cron
- Greps both log files for ERROR, CRITICAL, Exception, Failed, crash patterns
- Outputs filtered summary to `/data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data/error-summary.log`
- Includes: full startup sequence (mod loading, initialization), all errors with line numbers, timestamps

**Skill execution**:
1. **SSH** to 192.168.2.151 and reads the pre-filtered error-summary.log
2. **Analyzes** for quick interpretation
3. **Outputs**:
   - ✅ `Server healthy` (no errors)
   - ⚠️ `Warnings found:` with details
   - ❌ `Critical errors:` with timestamps and line numbers

## When to Use This Skill

**Best for scheduled/automated monitoring:**
- Remote triggering or cron-based checks
- Alerts when you're not in a session
- Periodic health monitoring

**Not needed for interactive checks:**
- For real-time "check logs now" requests, use direct SSH instead (faster, cheaper)
- Skill adds agent overhead; direct SSH is 1-2k tokens vs 5-10k for the skill

## Direct SSH Alternative (Recommended for Interactive Use)

```bash
# Quick health check (reads pre-filtered summary)
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 \
  "sudo cat /data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data/error-summary.log | head -50"

# Force refresh the filter script (instant)
ssh -i ~/.ssh/sitehost1 will@192.168.2.151 \
  "sudo /usr/local/bin/filter-errors.sh && cat /data/coolify/applications/kjbe9vn1omxtdnjzyiopjlrs/data/error-summary.log"
```

## Notes

- Filter script updates every 1 minute, so results are always fresh
- Startup sequence is captured in full (mod loading, initialization, errors)
- Use this skill for automation; use direct SSH for interactive checks

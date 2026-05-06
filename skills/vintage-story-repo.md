# vintage-story-repo

Maintain and manage the Vintage Story server repository. Update versions, manage mods configuration, validate repository state, and commit changes.

## Parameters

- **action** (required): The operation to perform
  - `status` - Show git status and recent commits
  - `validate` - Validate repository structure
  - `version` - Show current game version
  - `update-version <version>` - Update game version
  - `list-mods` - List all configured mods
  - `add-mod <name>` - Add a mod to compose.yaml
  - `remove-mod <name>` - Remove a mod from compose.yaml
  - `diff` - Show uncommitted changes
  - `log` - Show recent commits

## Examples

- "What's the current game version?"
- "Update the game to version 1.23.0"
- "List all the mods in the config"
- "Add the betterarcheology mod"
- "Remove the walkingstick mod"
- "Show me what's changed"
- "Validate the repository"

## Notes

- All mod/version changes are automatically committed
- Changes are reflected in compose.yaml
- Repository is at C:\website-projects\vintage-story-server
- Commits include proper attribution

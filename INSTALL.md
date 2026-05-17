# Install / Update / Uninstall

## Prerequisites

- macOS or Linux (Windows via WSL2 should work)
- `bash` (any modern version; the install script is POSIX-ish)
- [Claude Code](https://claude.com/claude-code) installed

## First install

```bash
cd ~/your-projects-dir
git clone <future-url> claude-dev-kit
cd claude-dev-kit
./install.sh
```

What `install.sh` does:
1. Creates `~/.claude/commands/` if it doesn't exist
2. For each of the 9 kit commands, if `~/.claude/commands/<name>.md` already exists, backs it up to `~/.claude/commands/.cdk-backup-<YYYYMMDD-HHMM>/`
3. Copies `commands/*.md` into `~/.claude/commands/`
4. Prints the installed version and the list of commands

The install is **idempotent** — re-running it makes a fresh backup and re-installs cleanly. Safe to run any time.

Verify:
```bash
ls ~/.claude/commands/
# Should show 9 .md files: plan-project, start-next-chunk, finish-chunk,
# status, log-decision, log-note, log-issue, audit-plan, add-chunk
```

## Update to a newer version

```bash
cd ~/your-projects-dir/claude-dev-kit
git pull
./install.sh
```

Your existing commands are backed up first, then overwritten. If you'd been hand-editing a kit command (you shouldn't — fork the kit instead), the backup is in `~/.claude/commands/.cdk-backup-<timestamp>/<name>.md`.

## Per-project version pinning (optional)

The default install applies the kit globally — every project on your machine uses the same installed version. If you need to pin a specific project to an older kit version (e.g. because you don't want to upgrade mid-project):

```bash
# In your project root
mkdir -p .claude/commands
cp ~/your-projects-dir/claude-dev-kit/commands/*.md .claude/commands/
```

Claude Code uses project-level `.claude/commands/` in preference to user-level `~/.claude/commands/`. So copying the kit's commands into your project freezes them at the current version for that project.

To unpin (let the project use the global kit again): delete `.claude/commands/`.

## Uninstall

```bash
cd ~/your-projects-dir/claude-dev-kit
./uninstall.sh
```

This removes only the 9 known kit commands from `~/.claude/commands/`. It leaves alone:
- Any other files you've put in `~/.claude/commands/`
- The backup directories in `~/.claude/commands/.cdk-backup-*/`
- Project-level `.claude/commands/` overrides

If you want a clean slate, you can manually delete the backup directories afterward.

## Troubleshooting

### "Permission denied" on install.sh

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

### Claude Code doesn't see the new slash commands

- Restart Claude Code — it caches the slash command list on startup
- Run `ls ~/.claude/commands/` to confirm the files are actually there
- Confirm the files have a YAML frontmatter block at top with `description:`

### `/plan-project` says it can't find the templates

The templates live in `<kit>/templates/` relative to the kit repo, not relative to where Claude Code is running. The kit commands reference templates by absolute path inferred at install time. If you moved the kit repo after installing, re-run `./install.sh` from the new location so the commands pick up the new path.

(Note: in v1, the `/plan-project` command instructions reference templates by relative path inside the command file. If your install needs an absolute path, the command will tell you it can't find the templates and suggest re-running `./install.sh`.)

### A kit command behaves differently in one project vs another

Check if that project has `.claude/commands/<name>.md` — a project-level override takes precedence over the user-level kit install. Either delete the project override or sync it with the kit's version.

### Commits got a `Co-Authored-By: Claude` trailer despite the kit's policy

The kit's commands never add Claude attribution. If you're seeing it:
- Check if your `CLAUDE.md` has `commit_style.trailer:` set with a Claude line — if so, remove it
- Check if another tool (e.g. a custom hook, a different agent) is adding the trailer outside the kit's control

### "Reverting" to a previous version

```bash
cd ~/your-projects-dir/claude-dev-kit
git checkout v0.9.0   # or whatever previous tag/SHA
./install.sh
```

Or restore from the most recent backup:
```bash
cd ~/.claude/commands/.cdk-backup-<timestamp>/
cp *.md ~/.claude/commands/
```

## Manual install (no script)

If you don't want to run `install.sh`, you can copy the commands manually:

```bash
mkdir -p ~/.claude/commands
cp ~/your-projects-dir/claude-dev-kit/commands/*.md ~/.claude/commands/
```

You'll lose the automatic backup behavior, but it works.

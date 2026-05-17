---
description: Read-only summary of project status. Prints current chunk, progress, recent commits, open issues. Does not modify anything.
---

You have been invoked for a read-only project status check. Do not edit files. Do not commit.

## What to do

1. **Read `STATUS.md`** at the repo root. If it doesn't exist, tell the user this project hasn't been planned yet and recommend `/plan-project`. Stop.

2. **Read `CLAUDE.md`** to get `project_name` from the `## Project commands` block.

3. **Run `git log --oneline -5`** to get recent commits for context.

4. **Compose a compact summary** and send it to the user. Shape:

```
Project: <project_name>
Progress: <N> / <total> chunks complete

Active: Chunk <NN> — <title>  <status_emoji>
  Doc: docs/chunks/chunk-<NN>-<slug>.md
  Started: <Last updated date from STATUS, if 🟡>

Most recent commit: <short sha> — <message line 1>

Open issues: <count, or "none">
Blockers: <list any chunks marked ⛔, or "none">

Decision log (most recent 3):
  - <recent decision 1>
  - <recent decision 2>
  - <recent decision 3>

Cross-session notes (most recent 3):
  - <recent note 1>
  - <recent note 2>
  - <recent note 3>

Next: <chunk N+1 title, or "all complete">
```

Trim sections that are empty (don't render "Open issues: none" if you can render "Open issues: 2 (see STATUS.md)"). Keep the whole output under 25 lines.

5. **Suggest next move** in one line at the end:
   - If a chunk is 🟡 in progress: "To resume, run `/start-next-chunk`."
   - If next chunk is ⬜ pending: "To start the next chunk, run `/start-next-chunk`."
   - If all chunks done: "v1 is complete. Run `/plan-project` to scope v2."
   - If a chunk is ⛔ blocked: "Blocker on chunk N — see Open issues in STATUS.md."

## Anti-patterns

- Do not edit STATUS.md or any other file. This command is strictly read-only.
- Do not commit anything.
- Do not start a chunk or run any workflow. The user can run `/start-next-chunk` if they want to begin.
- Do not dump the entire STATUS.md back to the user — they can open it themselves. Summarize.

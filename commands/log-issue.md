---
description: Append a bug, blocker, or unresolved issue to STATUS.md's Open issues. Optionally flag a chunk as ⛔ blocked.
---

You have been invoked to log an issue (bug, blocker, surprise) that needs attention. Optionally also flag a chunk as ⛔ blocked so `/start-next-chunk` refuses to proceed past it.

## Parse the invocation

The user may have invoked with one of these shapes:
- `/log-issue <text>` — log without blocking
- `/log-issue --block chunk-NN <text>` — log AND mark chunk NN as ⛔ blocked
- `/log-issue` alone — ask for details

If the text is missing, ask: "What's the issue? (Be specific — bug, blocker, or unresolved question.) And should it block a specific chunk? If yes, which one?"

## What to do

1. **Read `STATUS.md`**.

2. **Append to the Open issues section** under a `**Chunk NN (YYYY-MM-DD)**` heading (NN = active chunk if 🟡 exists, else "general"). Today's date. Example shape:

```md
**Chunk 03 (2026-05-17)**

- **<one-line summary>** — <2–3 sentences with context: what was tried, what
  failed, what the user/next-session needs to investigate. If reproducible,
  include the steps. If known workaround exists, note it.>
```

3. **If `--block chunk-NN` was specified:**
   - In the Chunk progress table, change chunk NN's status emoji to ⛔
   - Add a one-line reference under the chunk row pointing at the Open issues entry (e.g. `Blocked by: see Open issues 2026-05-17`)
   - Update **At a glance**: if the blocked chunk is the next pending chunk, add a `**Blocker:** Chunk NN — <one-line summary>` row

4. **Save STATUS.md.**

5. **Confirm to the user**:
   - If no `--block`: "Logged to Open issues under Chunk NN."
   - If `--block`: "Logged to Open issues and marked Chunk NN as ⛔ blocked. `/start-next-chunk` will now refuse to start that chunk until the issue is cleared."

## Unblocking later

When the issue is resolved, the user can:
- Edit STATUS.md directly to flip ⛔ back to ⬜ and remove the blocker reference
- Or run a future kit command like `/unblock chunk-NN` (not in v1)

Document this in the confirmation message if you set a block: "To unblock later, manually edit STATUS.md to flip the ⛔ back to ⬜."

## Anti-patterns

- Do not commit STATUS.md from this command. Same reasoning as the other log commands — logging is working memory.
- Do not block a chunk without the explicit `--block` flag. The block is a strong signal; require user intent.
- Do not log issues for things that are out of scope but harmless. Those are `/log-note` material.
- Do not add assistant attribution to STATUS.md.

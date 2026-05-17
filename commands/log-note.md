---
description: Append a note to STATUS.md's Cross-session notes. For caveats, surprises, and out-of-scope ideas the next session should know.
---

You have been invoked to log a cross-session note — something the current session noticed that the next session needs to know but isn't a formal architectural decision.

## What to do

1. **Capture the note text** from the user's invocation message. If they ran `/log-note <text>`, use `<text>`. Otherwise ask: "What note should I log? (One or two sentences.)"

2. **Read `STATUS.md`** and locate the **Cross-session notes** section.

3. **Determine the active chunk** — find the 🟡 in-progress chunk. If none is in progress, accept "general" or ask which chunk this relates to.

4. **Append the entry** under a `**Chunk NN (YYYY-MM-DD)**` heading. If one for today already exists, add a new bullet under it. Example shape:

```md
**Chunk 03 (2026-05-17)**

- <Note text. Useful for: "I noticed X was missing from chunk N's doc",
  "Out-of-scope idea: ...", "Found a quirk with library Y", "The mockup
  has a typo I left alone". Be specific about what the next session should
  do (or NOT do) about it.>
```

5. **Save STATUS.md.**

6. **Confirm to the user** in one line: "Logged to STATUS Cross-session notes under Chunk NN."

## When to use which log command

- **`/log-decision`** — architectural choices that constrain later chunks. Future sessions should treat these as load-bearing.
- **`/log-note`** — context that's useful but not load-bearing. Out-of-scope ideas, caveats, surprises, doc errata.
- **`/log-issue`** — actual bugs or blockers that need attention.

If you're unsure which the user wants, ask. Two of the three is fine if the boundary is fuzzy — e.g. a discovered library quirk that's both a "caveat" and a "decision to work around it" can go in both.

## Anti-patterns

- Do not commit STATUS.md from this command. Logging is working memory; commits happen at chunk boundaries.
- Do not log "TODO" items that should be tracked as tasks in TodoWrite instead. Notes are for context the next session needs, not your own task list.
- Do not add assistant attribution to STATUS.md.

---
description: Append a one-line entry to STATUS.md's Decision log. Discoverable shortcut for what'd otherwise be a manual STATUS edit mid-session.
---

You have been invoked to log a decision the current session made that affects later chunks.

## What to do

1. **Capture the decision text** from the user's invocation message. If they ran `/log-decision <text>`, use `<text>` as the decision body. If they invoked with no argument, ask them: "What decision should I log? (One or two sentences.)"

2. **Read `STATUS.md`** and locate the **Decision log** section.

3. **Determine the active chunk** — find the 🟡 in-progress chunk in the table. If none is in progress, ask the user which chunk this decision relates to (or accept "general" / "cross-cutting").

4. **Append the entry** under a `**Chunk NN (YYYY-MM-DD)**` heading. If a heading for the active chunk + today's date already exists, add a new bullet under it. Otherwise create a new heading and start a bullet list. Example shape:

```md
**Chunk 03 (2026-05-17)**

- <Decision text goes here. Be specific about WHAT was decided, WHY, and what
  later chunks should know. End with which chunks are affected if it's not
  obvious.>
```

5. **Save STATUS.md.**

6. **Confirm to the user** in one line: "Logged to STATUS Decision log under Chunk NN."

## Anti-patterns

- Do not commit STATUS.md from this command. The current session will pick it up at `/finish-chunk` and commit it as part of the chunk closeout. Logging is a working-memory operation, not a milestone.
- Do not log empty or vague decisions ("decided to be careful" — useless). If the user's input is too thin, ask for the rationale and the affected scope.
- Do not duplicate an existing log entry. Read what's there first.
- Do not add a co-author trailer or assistant attribution to STATUS.md.

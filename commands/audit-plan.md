---
description: Plan-agent critique of the remaining chunks given what's shipped so far. Catches drift mid-project. Outputs a report; does not modify anything without approval.
---

You have been invoked to audit the project's plan mid-stream. After several chunks have shipped, reality has diverged from the original plan in ways big or small — decisions logged, scope shifted, new constraints discovered. This command asks a Plan agent to read what's shipped and what remains, and surface drift before chunk N+1 falls apart.

## When to run

Recommend this after roughly every 4–5 chunks ship, or whenever STATUS's Decision log has grown more than a handful of entries, or whenever the user feels the plan no longer reflects reality.

## What to do

### 1. Read the current state (you, not the agent)

- `STATUS.md` — Chunk progress table, Decision log, Cross-session notes, Open issues
- `PROJECT_BRIEF.md` — original chunk overviews and cross-cutting decisions
- `CLAUDE.md` — Project commands block, architecture
- The remaining chunk docs — `docs/chunks/chunk-NN-*.md` for every chunk not yet 🟢 done. Read them all (they should be skimmable).

Note which chunks are done, what decisions were logged, what notes flag potential drift.

### 2. Launch one Plan agent

Use the `Agent` tool with `subagent_type: "Plan"`. Give it a self-contained brief:

```
Audit the remaining chunks of this project for drift, given what's shipped so far.

What's shipped (with decisions logged along the way):
<paste the done chunks from STATUS table + the Decision log entries + the
Cross-session notes verbatim>

What remains (chunk docs):
<paste, or summarize and reference, each remaining chunk's Goal + Scope-in + Files>

Original architecture decisions (from PROJECT_BRIEF):
<paste the cross-cutting decisions section>

Critique the remaining chunks. Specifically look for:
1. Drift — chunks whose original scope no longer fits the decisions logged in flight
2. Order issues — has a later chunk's dependencies now been satisfied by an earlier chunk's expanded scope?
3. Granularity — chunks that should be split (too large given new complexity) or merged (too small now that adjacent work happened)
4. Missing chunks — work that should be its own chunk but isn't (often: settings UX, error handling, accessibility, perf, README, telemetry)
5. Newly-redundant chunks — work already accidentally done by an earlier chunk
6. Cross-cutting concerns — anything that should be promoted to PROJECT_BRIEF instead of repeated per-chunk

Return a markdown report under 800 words. Use the structure:
- "What's still on track" (brief — just the parts that are fine)
- "Drift detected" (specific, with chunk references and a recommended action per item)
- "Recommended changes" (concrete: edit chunk doc X, split chunk Y, add a new chunk between Z and W)
- "No-action items" (things you flagged but on reflection are fine)

Be specific. Reference chunk numbers and decision-log entries by date.
```

### 3. Present the report to the user

Render the agent's report verbatim to the user. Then add a short message:

```
Audit complete. Three options:

1. **Apply the recommended changes** — I'll make the chunk-doc edits and STATUS updates
   per the report. (Confirm each change before writing.)
2. **Apply some but not all** — tell me which items to action.
3. **No changes** — I'll just log the audit in STATUS Cross-session notes for reference.
```

Wait for the user.

### 4. Apply changes (only if user approves)

If the user picks option 1 or 2:
- For each approved change, make the edit (chunk doc, STATUS, or PROJECT_BRIEF — the report should specify which file)
- Confirm each significant change before writing
- Log the audit conclusion as a STATUS Decision log entry: "**Audit (YYYY-MM-DD)**" with bullets summarizing what changed and why
- Do NOT commit — leave the changes for the next `/finish-chunk` to pick up, or let the user commit manually

If the user picks option 3:
- Log a STATUS Cross-session notes entry: "**Audit (YYYY-MM-DD)**" with a one-paragraph summary
- Do not modify anything else

## Anti-patterns

- Do not modify anything without user approval. The audit is advisory.
- Do not start a chunk or run `/start-next-chunk` from inside this command. Audit is read-mostly.
- Do not call the Plan agent more than once per invocation. One critique, presented, then decisions.
- Do not commit anything from this command. Leave changes uncommitted so they fold into the next chunk's commit.
- Do not add assistant attribution to STATUS or any file the audit modifies.

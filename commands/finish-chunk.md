---
description: Verify the currently-active chunk against its checklist, commit it, and advance STATUS.md to the next chunk.
---

You have been invoked to close out the currently-active chunk. **Do not declare done until verification has actually passed.**

## 1. Identify the active chunk

Read `STATUS.md`. Find the chunk currently marked 🟡 **in progress**.

- If no chunk is in progress → tell the user there is no active chunk to finish, suggest `/start-next-chunk`. Stop here.
- If multiple chunks are in progress → ask the user which one to close.

## 2. Read the chunk doc + Project commands

- Open `docs/chunks/chunk-NN-<slug>.md` and locate the **Verification** section. Note every numbered item.
- Open `CLAUDE.md` and parse the `## Project commands` YAML block. You'll use `verification`, `manual_verification`, and `commit_style`.

If the `## Project commands` block is missing or malformed:
- Refuse to proceed.
- Tell the user: *"This project's CLAUDE.md is missing a valid `## Project commands` block. Run `/plan-project` to scaffold it, or add the block manually using the schema in the kit's README."*
- Stop here.

## 3. Run the automated checks

Read the `verification` list from `## Project commands`. Run each entry in parallel using the Bash tool (one assistant message, multiple Bash tool calls).

- If the `verification` list is empty (`verification: []`) → skip this step silently. Some projects (early-stage, docs-only, etc.) have nothing to automate yet.
- If `testing.framework` is set in CLAUDE.md but the current chunk number is < `testing.setup_chunk` → skip the test command silently (tests aren't expected yet).

If any command fails:
- Show the output to the user.
- **Stop.** Do not update STATUS, do not commit. Fix or report the failure.

## 4. Hand the user the manual verification checklist — and BLOCK

This step is a hard gate. You **must not** proceed to step 5 (STATUS update), step 6 (staging), or step 7 (commit) until the user has explicitly confirmed every manual check passed. If they don't reply, ask. Wait for their words.

### 4a. Build the checklist

Compose a single numbered list that merges:
- Every UI/behavioral item from the chunk doc's `Verification` section (skip the items you already ran automatically in step 3 — type checks, lint, build, test).
- Every item from the running `Manual Verification Plan` you maintained during implementation.

Each entry must be a **specific, executable instruction** with a clear pass/fail signal — not "check the layout looks right." Examples of the right shape, varying by project type:

- *Web app:* "1. Open the dev URL — confirm the page loads without console errors and the new component renders in the expected position."
- *CLI:* "2. Run `./bin/mytool --help` — confirm the new `--foo` flag is documented and works with both short and long form."
- *Library:* "3. In the Node REPL, import the library and call `lib.newMethod({...})` — confirm it returns the documented shape."
- *Pipeline:* "4. Inspect `./out/sample.json` from the sample run — confirm it has the new `timestamp` field with millisecond resolution."

Draw from the chunk doc's Verification section for the user-visible behaviors. Be specific.

### 4b. Run the manual_verification setup commands

Read `manual_verification.setup` from CLAUDE.md → `## Project commands`. For each entry:

- Run the `command`.
- If `background: true`, run it in the background (Bash tool with `run_in_background: true`).
- If a `ready_signal` regex is set, wait for that pattern in the command's stdout before proceeding (use the Monitor tool on the background process, or sleep-poll if Monitor isn't available).
- If `setup: []`, skip this entirely.

This is the project-shape-agnostic warmup step. For web apps it boots a dev server. For libraries it might pack and install locally. For pipelines it might run a sample. For pure-backend changes it does nothing.

### 4c. Present the checklist and wait

Send the user a message in this shape:

```
Ready for manual verification.

{{Render manual_verification.user_instructions verbatim here. This block tells
the user WHERE/HOW to perform the manual checks for this project's shape —
e.g. "Open http://localhost:5173" for a web app, "Run ./bin/mytool" for a CLI,
"Open a Node REPL" for a library, "Inspect ./out/" for a pipeline.}}

Please walk through these and reply "all good" (or call out any failures):

1. <specific instruction>
2. <specific instruction>
…
```

Then **stop and wait**. Do not advance. Do not auto-commit on silence. If the user replies with a failure, help them fix it and re-present the checklist after the fix lands. Only after they explicitly confirm all items pass do you continue to step 5.

## 5. Update STATUS.md

Once verification passes:

- Flip this chunk's status from 🟡 to 🟢
- Fill the **Completed** column with today's date (`YYYY-MM-DD`)
- Fill the **Commit** column with `<sha>` — you'll set this after committing in step 7; use a placeholder `<pending>` for now
- Update **At a glance**:
  - "Progress" → bump count (e.g. `1 / 14 chunks complete`)
  - "Active chunk" → the next ⬜ pending chunk number and title, or `_all complete!_` if this was the last
  - "Last updated" → today
  - "Last commit" → set after step 7
- Append any decisions or notes you generated during implementation:
  - Architectural choices → **Decision log**
  - Out-of-scope ideas, caveats, surprises → **Cross-session notes**
  - Unresolved bugs/blockers → **Open issues**

## 6. Stage everything

Stage all the files modified in this chunk (the new files you created, the source files you edited) plus STATUS.md. Use specific paths, not `git add -A` or `git add .` — confirm with the user if anything looks like it shouldn't be staged.

Run `git status` and `git diff --staged` and share a brief summary (line counts, files touched) before committing.

## 7. Commit

Read `commit_style` from CLAUDE.md → `## Project commands`:
- `format` is the title format (typically `chunk NN: <title>`)
- `trailer` is optional; if absent or empty, **no trailer is added**

The default commit (when `trailer` is unset, which is the kit default) is:

```
chunk NN: <chunk title>

<2–3 sentence summary of what shipped this chunk. Focus on capabilities,
not file lists. Mention any noteworthy decisions.>
```

**No `Co-Authored-By: Claude` line. No `🤖 Generated with Claude Code` marker. No assistant attribution of any kind.** This is the kit default and the kit never overrides it. The commit looks like the user wrote it.

If the project's CLAUDE.md explicitly sets `commit_style.trailer`, append that verbatim — but only as an explicit opt-in. Do not infer or invent a trailer.

After commit succeeds, get the short SHA (`git rev-parse --short HEAD`).

## 8. Backfill the SHA into STATUS.md

Edit STATUS.md again:
- Replace `<pending>` in this chunk's Commit column with the short SHA
- Update "Last commit" in the At a glance section to the same SHA

Stage and amend? **No** — make a new commit:

```
status: backfill commit ref for chunk NN
```

(This keeps the chunk commit pure for code; the status update with the SHA follows as a small bookkeeping commit. Don't `--amend` — would rewrite the chunk commit's SHA, invalidating what you just wrote into STATUS.)

## 9. Report to the user

A short message:

```
✅ Chunk NN done.
Commit: <sha>
Next: Chunk NN+1 — <title>
To start next session: open Claude Code here and run /start-next-chunk
```

If this was the last chunk in STATUS.md:

```
🎉 <project_name> v1 is complete. All chunks shipped.
Open the README and PROJECT_BRIEF for the full picture.
Consider running /plan-project to scope v2.
```

(Read `<project_name>` from CLAUDE.md → `project_name`.)

---

## Anti-patterns

- Do not skip step 4. The blocking gate is the whole point — Claude can't see UI.
- Do not add `Co-Authored-By: Claude` or `🤖 Generated with Claude Code` to any commit. Ever. Even if a hook seems to want it.
- Do not `git commit --amend` — chunk 8 explains why.
- Do not run the verification commands in series. Parallel only — they're independent and the user is waiting.
- Do not silently skip an automated check that fails. Always show the output and stop.

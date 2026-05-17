---
description: Resume the in-progress chunk, or start the next pending chunk. Reads STATUS.md to determine which.
---

You have been invoked at the start of a work session. Follow this workflow strictly. **Do not begin implementation until the user has confirmed scope.**

## 1. Read STATUS.md

Open `STATUS.md` at the repo root and identify the chunk to work on:

- If exactly one chunk is 🟡 **in progress** → that's the chunk. You're resuming.
- If no chunk is in progress → the **first** ⬜ pending chunk is the chunk. You're starting fresh.
- If multiple chunks are in progress → that's an error state. Tell the user and ask which to resume.
- If every chunk is 🟢 done → congratulate the user. Read CLAUDE.md → `project_name` for the project name; say "`<project_name>` v1 is complete." Offer to scope a v2 with `/plan-project` or assist with something else. Stop here.

If `STATUS.md` doesn't exist → tell the user this project hasn't been planned yet, and recommend running `/plan-project` first.

## 2. Verify prerequisites

Open the chunk's doc at `docs/chunks/chunk-NN-<slug>.md`. Read the **Dependencies** section. For every dependency listed, verify STATUS.md shows it 🟢 done. Also check that no chunk before this one is marked ⛔ blocked.

If any prerequisite is not done or any earlier chunk is blocked:
- **Refuse to start this chunk.**
- Tell the user which earlier chunk is blocking and what its status is.
- Stop here.

## 3. Read the chunk doc fully

Internalize:
- **Goal** — one paragraph at top
- **Scope (in / out)** — exact boundary
- **Files to create or modify** — paths
- **Detailed tasks** — numbered steps
- **LLM prompts** (if applicable) — full text + schemas
- **Verification** — how you'll prove this chunk is done

## 4. Read context outside the chunk doc

- **`CLAUDE.md`** — auto-loaded by Claude Code, but re-read the `## Project commands` block specifically. You'll need `verification`, `manual_verification`, `testing`, and `commit_style` later.
- **`PROJECT_BRIEF.md`** — focus on "Cross-cutting architecture decisions." These apply across every chunk.
- **`STATUS.md` → "Decision log"** — choices earlier chunks made that affect what you build.
- **`STATUS.md` → "Cross-session notes"** — caveats from earlier sessions.
- **`STATUS.md` → "Open issues"** — anything that might be a blocker.

Also read any reference materials the chunk doc cites (mockup folders, design specs, RFCs, prior art) — the doc may give specific paths and line numbers.

## 5. Confirm scope with the user

Send the user a brief message — **no more than 8 lines**:

```
Picking up chunk NN: <title>
Goal: <one-sentence goal from the doc>
I'll create roughly: <3–5 most important new files>
Modify: <key existing files>
Verification: <one-line summary>
Status: <"resuming this chunk — N/M tasks done" if 🟡, or "starting fresh" if ⬜>
Anything to adjust before I start?
```

Then **wait for the user to confirm** before doing anything else.

If they want to modify scope, discuss it. Update the chunk doc only if the user explicitly asks — otherwise capture the deviation in STATUS "Cross-session notes" when you commit.

## 6. Mark the chunk in-progress

Once the user has approved:

- Edit STATUS.md:
  - Flip this chunk's status from ⬜ to 🟡 (only if it was ⬜)
  - Set "Active chunk" to this chunk
  - Set "Last updated" to today's date

- Stage and commit STATUS.md alone:
  ```
  status: start chunk NN
  ```
  No trailer, no co-author line — the kit never adds assistant attribution to commits.

## 7. Set up TodoWrite

Use the `TodoWrite` tool to break the chunk's "Detailed tasks" into trackable todos. Roughly one todo per numbered task in the doc, possibly grouped if some are tiny. Mark the first one `in_progress`.

## 8. Begin implementation

Work through the tasks in order. Adhere to:

- **Scope discipline.** If you spot something worth doing that's out of scope, append it to STATUS "Cross-session notes" — don't do it now.
- **Architecture discipline.** Cross-cutting decisions from PROJECT_BRIEF and STATUS Decision log apply across every chunk; don't violate them. If you have a strong reason to deviate, surface it to the user first.
- **Test discipline.** As you write non-trivial logic — parsers, validators, state machines, repository methods, data transforms, prompt-output handlers, anything with branches — write a unit test next to it. The test framework is declared in CLAUDE.md → `testing.framework`; tests are mandatory from the chunk noted in CLAUDE.md → `testing.setup_chunk` onward. Before that chunk, skip tests silently. Skip tests for: pure styling/visual work, components that only render props, placeholder code, anything where the test would just restate the implementation. The bar: would this regress silently if I broke it? If yes, test it.
- **Manual verification accumulation.** You can't see UI or feel an interaction. As you implement, maintain a running **Manual Verification Plan** — a numbered list of user-facing behaviors only the user can confirm (visual match, animations, hover/click/keyboard, streaming feels live, persistence across reload, etc.). Keep it in a TodoWrite item titled `Manual Verification Plan` or a scratch block. `/finish-chunk` will merge this list with the chunk doc's Verification section and present it to the user as a blocking gate.
- **Verification at the end.** Each task complete → mark its todo done. After all tasks, run through the chunk doc's Verification section yourself before handing off to `/finish-chunk`.

## 9. When implementation feels done

Tell the user something like:

> Implementation looks complete. Suggest running `/finish-chunk` to verify against the chunk's checklist and commit.

Do **not** auto-run `/finish-chunk`. The user decides when the chunk is shippable.

---

## Anti-patterns

- Do not add `Co-Authored-By: Claude` or `🤖 Generated with Claude Code` to any commit. The kit never adds assistant attribution.
- Do not skip the scope-confirmation step. Even on resume, send the brief message — surfaces any drift before you spend cycles.
- Do not modify chunk docs or PROJECT_BRIEF.md without telling the user. Those are the contract. If a doc was wrong, log the correction in STATUS "Cross-session notes".
- Do not start a chunk whose dependencies aren't ✅. Refuse and point at the blocker.

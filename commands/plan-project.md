---
description: Interactive planning workflow. Asks about the project, explores existing code or reference materials, asks adaptive clarifying questions, validates the chunk breakdown with a Plan agent, and writes PROJECT_BRIEF + chunk docs + STATUS + CLAUDE.md.
---

You have been invoked to plan a new project (or replan an existing one). This is the most complex command in the kit — it walks the user through the same workflow that produces a chunked, sessionable, multi-week build plan. **Do not write any project files until the user has approved the plan via `ExitPlanMode`.**

## 0. Enter plan mode

If you are not already in plan mode, enter it now. Planning is plan-mode-native — you may only edit the plan file at `~/.claude/plans/<plan-id>.md`. All read tools are available.

If the user's invocation message included a project description, start there; otherwise begin with step 1.

## 1. Gather inputs from the user

Send one short message asking — at most three questions, combined into one turn so the user answers in one go:

```
A few questions to scope this:

1. Briefly, what are we building? (1–3 sentences is fine.)
2. Is there a reference mockup, design file, existing prototype, RFC, or notes
   I should read first? If yes, give me the path(s).
3. Any hard constraints I should know up front? (tech stack, deadline,
   non-negotiable libraries, "do not use X")
```

Wait for their reply.

Also auto-detect context:
- Is the current working directory a git repo? Run `git status` and `git log --oneline -5` (cheap reads).
- Are there source files? `ls` and `find . -maxdepth 2 -type f | head -30` to get a sense.
- Is there a `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, etc. that hints at the tech stack?

Capture this in your working memory — you'll use it to seed the clarifying questions and verification commands later.

## 2. Explore (only if there's something to read)

If the user pointed you at reference materials (mockup folder, design files, existing prototype, RFC), or if the repo has substantive existing code:

- **Launch up to 3 parallel `Explore` agents in a single message** (multiple Agent tool calls in one assistant turn).
- Allocate agents intentionally:
  - 1 agent for the reference mockup / design materials (if any)
  - 1 agent for the existing codebase (if any) — file structure, tech stack, key components, what's working vs broken
  - 1 agent for surrounding context (related docs, READMEs, recent commits)
- Give each agent a thorough, self-contained prompt with the specific paths and what to report back. Aim for a comprehensive write-up — file inventory, design system, key components, tech stack hints, etc.

If there's nothing to explore (truly greenfield, no reference materials), skip this step.

## 3. Adaptive clarifying questions

Use `AskUserQuestion` to clarify the decisions that materially affect the chunk breakdown. **Do not use a fixed list** — the right questions depend on what exploration found and what the user said. Cover dimensions like:

- **Tech stack confirmation** (informs `verification` commands + `testing.framework`)
- **Architecture-defining choices** (e.g. database vs none, monolith vs services, native vs cross-platform, server-rendered vs SPA)
- **Persistence model** (none / localStorage / IndexedDB / SQL / NoSQL / cloud)
- **External services** (LLM provider if AI-powered, payment processor, auth provider, etc.)
- **Migration strategy if there's existing code** (greenfield vs preserve vs incrementally migrate)
- **Scope sizing** — how many chunks feel right? Small ~6, medium ~12, large ~20. Larger isn't better; smaller chunks ship more frequently.
- **Things explicitly out of scope for v1** (mobile, i18n, a11y depth, etc.)
- **Distribution target** (web app / CLI / library / mobile / desktop / extension / etc. — this determines the `manual_verification` shape later)

Constraints on the AskUserQuestion calls:
- At most 4 questions per call
- Each question has 2–4 options
- The first option should usually be your recommendation, marked `(Recommended)` with a brief rationale in the description
- Multi-select where the choices aren't exclusive

You can issue several rounds of AskUserQuestion if needed. Don't ask everything at once — pace it.

## 4. Draft the chunk breakdown internally

Based on the answers, draft a chronological chunk list. Guidelines:

- Each chunk is sized to ~1–3 days of focused work
- Each chunk is a coherent, shippable increment (not "tasks 47–63")
- Dependencies flow strictly forward — no chunk references a later one
- Aim for the scope size the user chose (~6 / ~12 / ~20)
- Cover the unsexy chunks: settings/config UI, error handling, empty states, accessibility, performance, README. These get forgotten in planning.

Each chunk needs (mentally for now, written later):
- A name and one-line goal
- Scope: in / out (explicit)
- Dependencies (other chunks)
- Files to create or modify
- Detailed tasks (numbered steps an implementer can follow)
- Verification (how to test the chunk end-to-end)

## 5. Plan-agent review

Launch **one** Plan agent (via the `Agent` tool with `subagent_type: "Plan"`) to critique the draft. Give it:

- The user's goal and constraints
- A summary of what exploration found
- Your draft chunk list
- A specific list of things to critique: ordering, dependencies, granularity (too coarse or too fine), missing chunks (settings UX, error handling, perf, a11y, README often get missed), cross-cutting concerns that should be stated once not per-chunk

Ask the Plan agent for under 600 words — critique only, not a full rewrite.

## 6. Incorporate the critique

Revise the chunk list based on what the Plan agent flagged. Tell the user what changed and why — one or two sentences per change is enough.

## 7. Write the plan file

Write your final plan to the plan-mode plan file (the path is shown in the plan-mode banner). Include:

- **Context** — why this work, end state, confirmed decisions
- **Architecture** — the cross-cutting decisions that apply to every chunk (tech stack, persistence approach, key patterns)
- **The N chunks (chronological)** — each with a one-paragraph overview, listed in order
- **Cross-cutting architecture decisions** — anything that applies to multiple chunks, stated once
- **File structure** to be created (PROJECT_BRIEF.md, docs/chunks/*.md, STATUS.md, CLAUDE.md)
- **Verification** — what the user can check after writing
- **Open questions** — anything still uncertain, flagged for the per-chunk docs

Use the structure of the Recipe Planner PROJECT_BRIEF as the reference shape — it's the canonical example, linked in `<kit>/examples/recipe-planner.md`.

## 8. ExitPlanMode

Call `ExitPlanMode` and wait for the user to approve.

If they don't approve, address their feedback and re-write/re-edit the plan, then re-call ExitPlanMode.

## 9. After approval, write the per-project files

The kit ships templates at `<kit>/templates/` that you populate from the plan:

| Template | Write to | Notes |
| --- | --- | --- |
| `CLAUDE.md.template` | `./CLAUDE.md` | Includes the **`## Project commands`** block populated from the user's tech-stack answers. This is what `/finish-chunk` reads. |
| `STATUS.md.template` | `./STATUS.md` | Initial state — all chunks ⬜, Active = chunk 1, Progress = 0/N. |
| `PROJECT_BRIEF.md.template` | `./PROJECT_BRIEF.md` | Filled from the chunk breakdown and architecture decisions. |
| `chunk.md.template` | `./docs/chunks/chunk-NN-<slug>.md` | One per chunk, filled with the detail you drafted in step 4 (and refined in step 6). |

Substitute `{{PLACEHOLDER}}` tokens with the appropriate values. Common placeholders: `{{PROJECT_NAME}}`, `{{TAGLINE}}`, `{{TECH_STACK}}`, `{{CHUNK_TABLE}}`, `{{VERIFICATION_COMMANDS}}`, `{{MANUAL_VERIFICATION_SETUP}}`, `{{MANUAL_VERIFICATION_INSTRUCTIONS}}`, `{{TESTING_FRAMEWORK}}`, `{{TESTING_SETUP_CHUNK}}`. Each template's header comment lists its placeholders.

**Critical: the `## Project commands` block in CLAUDE.md must be valid YAML with the schema documented in `<kit>/README.md`.** Without it, `/start-next-chunk` and `/finish-chunk` will fail.

Use `mkdir -p docs/chunks` before writing the chunk docs.

## 10. Offer to commit (do not auto-commit)

Once the files are written, ask the user:

```
Planning files are written. Want me to commit them?
- PROJECT_BRIEF.md (root)
- STATUS.md (root)
- CLAUDE.md (root)
- docs/chunks/chunk-NN-*.md (N files)

If yes, I'll stage just these and commit with message:
  plan: project brief, N chunk docs, and session continuity

(No PR, no push. Local commit only.)
```

If they say yes, commit them. **Do not add any `Co-Authored-By` trailer or assistant-attribution to the commit.** The commit looks like the user wrote it.

If they say no, leave the files staged (or unstaged — whichever they prefer).

## 11. Final message

```
Plan complete. {N} chunks scoped, all docs written.

To start chunk 1, open a fresh Claude Code session in this repo and run:
  /start-next-chunk

Quick reference:
- /status — see where you are anytime
- /log-decision, /log-note, /log-issue — append to STATUS mid-session
- /audit-plan — Plan-agent critique of remaining chunks (use after a few chunks ship)
- /add-chunk — insert a new chunk mid-project
- /finish-chunk — close out the current chunk (after manual verification)
```

---

## Anti-patterns (do not do these)

- Do not write code or app files during this command. Only docs.
- Do not skip the Plan-agent review — the critique catches real issues.
- Do not use a fixed list of clarifying questions. Adapt to what exploration found.
- Do not auto-commit. Always ask.
- Do not add `Co-Authored-By: Claude` or `🤖 Generated with Claude Code` anywhere. Not in commits, not in PRs, not in file headers, not in template fill-ins.
- Do not try to scope chunks of fixed-duration "1 day" — sizes vary; just aim for "single coherent shippable increment" of 1–3 days.

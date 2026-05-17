# Case study: Recipe Planner

Recipe Planner is a fictional project used to illustrate the kit end-to-end. It's a React + TypeScript + Vite web app — an AI-powered cooking companion where users browse AI-generated recipe cards, highlight any ingredient or step, and trigger one of four LLM actions (Scale, Substitute, Variation, Ask).

The project was planned as **14 chunks** using the planning workflow that's now codified in `/plan-project`:

| # | Chunk | What ships |
| --- | --- | --- |
| 01 | Foundation & Design System | CSS tokens, fonts, tsconfig, warm-aesthetic primitives |
| 02 | Application Shell | 3-column grid, top bar, stub sidebars |
| 03 | Types & Fixtures | TS interfaces + Pasta Carbonara demo data |
| 04 | Recipe Rendering Engine | Ingredient/step parser + every visual piece |
| 05 | Storage Layer | Async repo pattern over localStorage |
| 06 | LLM Service v2 | SSE streaming, zod validation, settings modal |
| 07 | Recipe Generation Flow (E2E) | First real LLM call: dish idea → recipe |
| 08 | Highlight & Popover Infrastructure | Selection detection, popover positioning |
| 09 | Scale + Substitute Actions | Two inline actions with streaming |
| 10 | Variation Branch Action | Spawn linked recipe variations from selection |
| 11 | Ask + Threads | Chat UI + anchored Q&A on a recipe |
| 12 | Left Sidebar Polish | Cookbook, search, pin, categories |
| 13 | Right Sidebar Polish | Meal-plan grid, tabs, active thread |
| 14 | Polish, Animations, A11y | Final pass before ship |

## What the kit produces (in Recipe Planner's repo)

After the inline planning workflow ran (the same workflow `/plan-project` now codifies):

```
recipe-planner/
├── PROJECT_BRIEF.md                    # 12 KB — front door
├── STATUS.md                           # ~3 KB — live dashboard
├── CLAUDE.md                           # ~4 KB — auto-loaded session context
├── docs/
│   └── chunks/
│       ├── chunk-01-foundation.md      # ~6 KB each
│       ├── chunk-02-shell.md
│       ├── ... (14 total)
│       └── chunk-14-polish.md
└── .claude/
    └── commands/                       # the original project-specific commands
        ├── start-next-chunk.md         # pre-CDK; will be deleted post-retrofit
        └── finish-chunk.md             # pre-CDK; will be deleted post-retrofit
```

## What ran when

- **Planning**: ~1 session, ~2 hours of conversation. Output: the brief + 14 chunk docs + STATUS + CLAUDE.md.
- **Chunk 01**: 1 session. Foundation work, mostly CSS + tsconfig + fonts. Manual verification: "background is the right warm cream, fonts render correctly, no TS errors."
- (Chunks 02–14 in progress / pending at time of writing this case study.)

## How sessions actually feel

A typical chunk session in Recipe Planner looks like:

1. Open Claude Code in the recipe-planner directory
2. Type `/start-next-chunk`
3. Claude reads STATUS, sees chunk 02 is next, reads the chunk doc + cross-session context, sends a short scope-confirmation message
4. Type "looks good"
5. Claude marks chunk 02 in-progress, commits STATUS, sets up TodoWrite, starts implementing
6. (Many tool calls, occasional clarifying questions, ~1–3 hours of work)
7. Claude says "implementation looks complete; suggest `/finish-chunk`"
8. Type `/finish-chunk`
9. Claude runs `npx tsc --noEmit`, `npm run lint`, `npm run build` in parallel — all pass
10. Claude boots `npm run dev` in the background, presents a manual verification checklist with specific items ("Open localhost:5173 — confirm the 3-column layout matches screenshot 01-overview")
11. Walk through the checklist in the browser
12. Type "all good"
13. Claude updates STATUS, commits with `chunk 02: Application Shell` + summary (no Claude attribution), backfills the SHA, reports done
14. Close the session

Next day: open a new session, `/start-next-chunk`, chunk 03 picks up.

## Why the manual verification gate matters

Claude can't see the UI. Without a blocking gate, the most common failure mode is "the code compiles, the tests pass, but the thing visually doesn't work." Recipe Planner's chunk 01 surfaced an example: the design tokens were ported but referenced `design/styles.css` lines 12–35, and the actual `:root` block lived in `design/RecipePlanner.html` lines 12–36. The code compiled. Vite ran. The page looked subtly wrong. The manual checklist caught it in 30 seconds.

This is why `/finish-chunk`'s step 4 blocks until you type "all good" — Claude is doing the part it's reliably good at (writing code that compiles), and you're doing the part only you can do (verifying it works for humans).

## Notes that informed the kit

- The first version of the workflow didn't have a manual verification gate; users would frequently `/finish-chunk` and discover a UI bug the next session. Adding the blocking gate was the single biggest improvement.
- The test discipline (write Vitest tests inline for non-trivial logic) was a chunk-01 addition after realizing some chunk-5+ logic was complex enough that "let it regress silently and find out later" was a real risk.
- The `manual_verification` block in CLAUDE.md was originally just `dev_server` and `dev_url`. Generalizing to `setup: [commands]` + `user_instructions: <text>` came from realizing not every project has a dev server — libraries, CLIs, pipelines, pure-backend changes all need different warmups.

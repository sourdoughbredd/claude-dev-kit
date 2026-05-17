# Claude Development Kit (CDK)

> Turn an ambitious project into a "one shippable chunk per session" state machine. Plan it once, build it across many sessions, never lose your place.

The CDK is a set of 9 [Claude Code](https://claude.com/claude-code) slash commands that scaffold and drive a chunked, session-resumable development workflow. Install once, use in any project.

## What problem this solves

Long projects don't fit in a single Claude Code session. You start, get partway through, hit context limits or wrap for the day, come back tomorrow — and now Claude has no idea where you were. You spend 20 minutes re-orienting before any new work happens.

The CDK fixes that with a simple discipline:
1. **`/plan-project`** breaks the project into chunks at the start
2. **`STATUS.md`** is the persistent state machine — single source of truth for "what's done, what's next"
3. **`CLAUDE.md`** is auto-loaded by Claude Code on every session start, teaches each fresh session the workflow
4. **`/start-next-chunk`** in a new session: Claude reads STATUS, picks up the right chunk, confirms scope, gets to work
5. **`/finish-chunk`** when done: runs verification (automated + manual), commits, advances STATUS to the next chunk
6. Repeat

A new session's startup cost goes from "20 minutes of re-orientation" to "one slash command."

## The 9 commands

### Core trio
| Command | What it does |
| --- | --- |
| **`/plan-project`** | Interactive planning workflow. Asks about your project, explores existing code or mockups, asks adaptive clarifying questions, validates the chunk breakdown with a Plan agent, then writes PROJECT_BRIEF + per-chunk docs + STATUS + CLAUDE.md. |
| **`/start-next-chunk`** | Resume an in-progress chunk or start the next pending chunk. Reads STATUS, verifies dependencies, confirms scope with you, then implements with test discipline and a running "Manual Verification Plan." |
| **`/finish-chunk`** | Close out a chunk. Runs automated checks in parallel, then **blocks on a manual verification checklist** (auto-starts your dev server or runs your setup commands so you can click through), updates STATUS, commits, advances to the next chunk. |

### Quality of life
| Command | What it does |
| --- | --- |
| **`/status`** | Read-only summary: current chunk, progress, recent commits, open issues. |
| **`/log-decision`** | Append a decision to STATUS Decision log. |
| **`/log-note`** | Append a note to STATUS Cross-session notes. |
| **`/log-issue`** | Append a bug/blocker to STATUS Open issues. Use `--block chunk-NN` to also flag a chunk as ⛔ blocked. |

### Mid-project safety nets
| Command | What it does |
| --- | --- |
| **`/audit-plan`** | Spawns a Plan agent to critique your remaining chunks given what's shipped. Catches drift before it compounds. |
| **`/add-chunk`** | Guided insertion of a new chunk mid-project. Updates STATUS table, creates a chunk doc from the template, validates dependencies. |

## Quick start

```bash
# 1. Clone the kit
cd ~/your-projects-dir
git clone https://github.com/sourdoughbredd/claude-dev-kit.git claude-dev-kit
cd claude-dev-kit

# 2. Install (copies commands into ~/.claude/commands/)
./install.sh

# 3. In any project, open Claude Code and run:
/plan-project
```

That's it. The planning workflow walks you through the rest.

See [INSTALL.md](INSTALL.md) for detailed install, update, uninstall, and troubleshooting.

## How project-specific bits are handled

The kit is **tech-stack-agnostic**. It works for web apps, CLIs, libraries, data pipelines, Rust, Go, Python, anything. The trick: `/plan-project` writes a `## Project commands` YAML block into your project's `CLAUDE.md` that declares the project's verification commands and how to set up for manual verification. The kit commands read this block at runtime.

Example for a Vite React project:

```yaml
project_name: "MyApp"
tech_stack: ["React 19", "TypeScript", "Vite"]
verification:
  - "npx tsc --noEmit"
  - "npm run lint"
  - "npm run build"
  - "npm test -- --run"
manual_verification:
  setup:
    - command: "npm run dev"
      background: true
      ready_signal: "Local:.*http://"
  user_instructions: |
    Open http://localhost:5173 in your browser. Walk through the checklist below.
testing:
  framework: "vitest"
  setup_chunk: 5
commit_style:
  format: "chunk NN: <title>"
```

Example for a Rust CLI:

```yaml
project_name: "MyTool"
tech_stack: ["Rust", "clap"]
verification:
  - "cargo check"
  - "cargo clippy -- -D warnings"
  - "cargo build --release"
  - "cargo test"
manual_verification:
  setup: []
  user_instructions: |
    Build is complete (`./target/release/mytool`). Exercise the new flags via the checklist below.
testing:
  framework: "cargo test"
  setup_chunk: 1
commit_style:
  format: "chunk NN: <title>"
```

Example for a Python library:

```yaml
project_name: "mylib"
tech_stack: ["Python 3.12", "pytest"]
verification:
  - "ruff check ."
  - "mypy src/"
  - "pytest"
manual_verification:
  setup:
    - command: "pip install -e ."
      background: false
  user_instructions: |
    The library is installed in editable mode. Open `python -i` and import it. Exercise the new APIs from the checklist below.
testing:
  framework: "pytest"
  setup_chunk: 1
```

Example for a pure-backend / no-runtime-verification project:

```yaml
project_name: "config-as-code"
verification:
  - "yamllint configs/"
  - "shellcheck scripts/*.sh"
manual_verification:
  setup: []
  user_instructions: |
    Review the diff against the checklist below. No runtime verification needed.
```

## What's NOT in the kit

Some intentional design choices:

- **No assistant attribution in commits or PRs.** The kit never adds `Co-Authored-By: Claude` or `🤖 Generated with Claude Code` to anything. Commits look like you wrote them. If you actually want a trailer, opt in via `commit_style.trailer` in your project's CLAUDE.md.
- **No global state, no daemon, no telemetry.** The kit is just markdown files in `~/.claude/commands/`. No data leaves your machine.
- **No git submodules.** The kit is cloned standalone and installed via `./install.sh`. Updates propagate via `git pull && ./install.sh`. Submodules add operational friction we don't need.
- **No automatic mobile/responsive scaffolding, no automatic CI setup, no opinion on your folder structure.** The kit drives a workflow; what you build is up to you.

## Anatomy

```
claude-dev-kit/
├── README.md              # you are here
├── INSTALL.md             # install / update / uninstall / troubleshooting
├── VERSION                # "1.0.0" — bumped manually on release
├── install.sh
├── uninstall.sh
├── commands/              # the 9 slash commands
│   ├── plan-project.md
│   ├── start-next-chunk.md
│   ├── finish-chunk.md
│   ├── status.md
│   ├── log-decision.md
│   ├── log-note.md
│   ├── log-issue.md
│   ├── audit-plan.md
│   └── add-chunk.md
├── templates/             # what /plan-project writes into your project
│   ├── CLAUDE.md.template
│   ├── STATUS.md.template
│   ├── PROJECT_BRIEF.md.template
│   └── chunk.md.template
└── examples/
    └── recipe-planner.md  # case study
```

## Compatibility

These commands rely on Claude Code-specific features:
- Slash commands at `~/.claude/commands/`
- Plan mode + `ExitPlanMode`
- `AskUserQuestion` tool
- `Explore` and `Plan` subagent types
- `TodoWrite` tool

They're not portable to other agentic CLIs without rewriting.

## License

MIT — see [LICENSE](LICENSE).

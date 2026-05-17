---
description: Guided insertion of a new chunk mid-project. Prompts for scope, creates the chunk doc from the template, updates STATUS, validates dependency chain.
---

You have been invoked to add a new chunk to the project's plan mid-stream. This happens when implementation surfaces work that should be its own chunk — usually after `/audit-plan` flags a gap, or when something new comes up that doesn't fit the active chunk's scope.

## What to do

### 1. Gather details from the user

Ask via a single message (or AskUserQuestion if you prefer structured options):

```
A few quick questions:

1. **Title** for the new chunk (short, noun-phrase, e.g. "Settings Modal" or
   "Error Recovery Layer")
2. **Slug** for the filename (lowercase, hyphenated, e.g. "settings-modal").
   Auto-suggest from the title if missing.
3. **One-paragraph goal** — what does this chunk accomplish?
4. **Insert where?** — pick a position. The new chunk becomes chunk N, and the
   chunk currently at position N becomes N+1, etc. You can pick a number, or
   "after chunk M" / "before chunk M".
5. **Dependencies** — which other chunks (by number) must be done first?
```

Wait for replies.

### 2. Validate

- The new chunk's `Dependencies` must all reference chunks with positions strictly **less than** the new chunk's insertion position. If a dependency would land at position ≥ new position, refuse and ask the user to either change the insertion position or drop the dependency.
- The slug must be unique (no `docs/chunks/chunk-NN-<slug>.md` already collides).
- The new chunk's position must be a valid integer in `[1, current_total + 1]`.

If anything fails validation, surface it clearly and stop.

### 3. Decide whether to renumber

If insertion is at the **end** (position = current_total + 1), no renumbering needed.

If insertion is **mid-list** (position ≤ current_total), all chunks at position ≥ new position get bumped by +1:
- Filename: `chunk-05-foo.md` → `chunk-06-foo.md`
- All internal references inside chunk docs (e.g. "Dependencies: chunks 3, 5") need to be updated to reflect new numbers
- STATUS.md table needs new rows + renumbered existing rows
- PROJECT_BRIEF.md chunk table needs the same

This is invasive. **Before doing any renumbering, show the user a preview**:

```
Inserting at position N will renumber:
  Chunk N (current "Foo") → Chunk N+1
  Chunk N+1 (current "Bar") → Chunk N+2
  ...

And will rename files:
  docs/chunks/chunk-NN-foo.md → docs/chunks/chunk-NN+1-foo.md
  ...

And will update cross-references in 4 chunk docs and PROJECT_BRIEF.md.

Proceed? (y/n)
```

Wait for confirmation.

### 4. Create the new chunk doc

Read `<kit-templates-dir>/chunk.md.template`. Substitute placeholders:
- `{{CHUNK_NUMBER}}` → padded to 2 digits (e.g. `04`)
- `{{CHUNK_TITLE}}` → user's title
- `{{CHUNK_GOAL}}` → user's one-paragraph goal
- `{{CHUNK_SCOPE_IN}}` → empty bullet list for now (user can fill in)
- `{{CHUNK_SCOPE_OUT}}` → empty
- `{{DEPENDENCIES}}` → "Chunk M, Chunk N" or "None"
- `{{FILES_TO_CREATE_OR_MODIFY}}` → empty
- `{{DETAILED_TASKS}}` → empty
- `{{REFERENCES}}` → empty
- `{{LLM_PROMPTS}}` → "(none for this chunk)" or empty
- `{{VERIFICATION}}` → empty
- `{{OPEN_QUESTIONS}}` → empty

Write to `docs/chunks/chunk-NN-<slug>.md`.

Note to the user: the doc is a skeleton — they'll want to flesh out the scope, tasks, files, and verification before starting the chunk. Suggest doing this now or via a quick `/plan-project --extend` follow-up (not implemented in v1; for now, manual edit).

### 5. Renumber existing chunks (only if mid-list insertion)

For each chunk at position ≥ new position (descending order to avoid filename collisions):
- Rename the file (`mv docs/chunks/chunk-OLD-slug.md docs/chunks/chunk-NEW-slug.md`)
- Update the heading inside the file (`# Chunk OLD — Title` → `# Chunk NEW — Title`)
- Update references inside the file to its own chunk number

Then sweep all chunk docs (including the new one and all renumbered ones) for cross-references to the renumbered chunks and update them.

Also update PROJECT_BRIEF.md's chunk table.

### 6. Update STATUS.md

- Insert a new row in the Chunk progress table at the right position (status ⬜, Completed —, Commit —)
- If renumbering happened, update existing rows' chunk numbers
- Update **At a glance** if the new chunk's position affects "Active chunk" or "Next" — usually not the case for mid-list inserts, but check
- Append a Decision log entry: "**Chunk add (YYYY-MM-DD)**" noting the insertion + why (paraphrased from the user's goal text)

### 7. Confirm to the user

```
✅ Chunk NN added: "<title>"
  Doc: docs/chunks/chunk-NN-<slug>.md (skeleton — fill in scope/tasks before starting)
  STATUS.md updated.
  {{ if renumbered: "Renumbered chunks M through K." }}

Next: Edit the new chunk doc to flesh out scope, files, tasks, and verification.
Then `/start-next-chunk` will pick it up in order.

(Nothing has been committed. Stage and commit when ready.)
```

## Anti-patterns

- Do not renumber chunks without showing a preview and getting confirmation. Renumbering is invasive — once-applied it's a manual revert.
- Do not create a chunk whose dependencies reference later chunks. Refuse.
- Do not auto-commit. Leave changes uncommitted so the user can review.
- Do not start the new chunk after creating it. Creation and execution are separate.
- Do not add assistant attribution to any file the command modifies.

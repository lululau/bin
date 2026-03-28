# git-fire subcommands design

## Problem

`git-fire` saves all working tree changes as a commit then immediately resets, leaving the commit as a dangling object. Currently there is no built-in way to list, inspect, or recover these fire commits.

## Solution

Add three subcommands to `git-fire`:

- `git fire list` — list all fire commits
- `git fire show <n>` — show full diff of the nth fire commit
- `git fire apply <n>` — restore the nth fire commit's changes to working tree (no commit)

## Discovery strategy

Fire commits are identified by commit message prefix `GIT ON FIRE:`.

1. **Primary**: `git reflog` — search all reflog entries for matching messages. Fast, has timestamps, 90-day default retention.
2. **Fallback**: `git fsck --unreachable --no-reflogs` — find dangling commits with matching messages. Covers cases where reflog has expired but objects haven't been GC'd.

Results are deduplicated (same commit hash may appear in multiple reflog entries) and sorted by timestamp, newest first.

## Script structure

Single file `git-fire` with function extraction and `case/esac` dispatch.

```
git fire          → fire()        — existing behavior, unchanged
git fire list     → fire_list()   — list fire commits
git fire show <n> → fire_show()   — git show <hash>
git fire apply <n> → fire_apply() — git cherry-pick --no-commit <hash>
```

### Core functions

**`_find_fire_commits()`**
- Returns array of `hash|timestamp` entries, newest first
- Primary: `git reflog --all --grep="GIT ON FIRE:" --format="%H|%gs"`
- Fallback: `git fsck --unreachable --no-reflogs` → filter dangling commits by message
- Deduplicate by hash

**`fire_list()`**
- Calls `_find_fire_commits()`
- Output format per line: `#N  <short_hash>  <timestamp>  <changed_files_count> files`
- File count via `git diff-tree --no-commit-id --name-only -r <hash> | wc -l`
- Empty result: "No fire commits found."

**`fire_show(<n>)`**
- N is 1-based index from list output
- Executes `git show <hash>`
- Invalid N: error with valid range

**`fire_apply(<n>)`**
- N is 1-based index from list output
- Executes `git cherry-pick --no-commit <hash>`
- Changes land in working tree + staging area, no commit created
- Conflicts: print message, let user resolve manually
- Invalid N: error with valid range

**`fire()`** — existing behavior, no changes

## Error handling

- Not in a git repo: error and exit
- No arguments: run existing fire flow
- Invalid subcommand: print usage

## Constraints

- No changes to existing `git fire` (no-argument) behavior
- No external dependencies
- Shell: zsh
- Single file, function extraction

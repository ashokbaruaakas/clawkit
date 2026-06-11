# AI Operator Contract

This file is the handoff contract for any new AI agent session working in this repository.

## Mission

Maintain Clawkit as a stable wrapper image around OpenClaw with automated release behavior.

## Source of Truth

- Runtime and usage: [README.md](README.md)
- Contribution policy: [CONTRIBUTING.md](CONTRIBUTING.md)
- Release automation: [.github/workflows/release-check.yml](.github/workflows/release-check.yml)
- Pending work: [.github/IMPROVEMENTS.md](.github/IMPROVEMENTS.md)

If these files disagree, treat workflow behavior in `.github/workflows/release-check.yml` as authoritative for release logic, then update docs to match.

## Non-Negotiable Rules

1. Do not push directly to `main`.
2. Use branch + PR workflow.
3. Keep docs in sync with behavior changes.
4. Preserve existing formatting conventions from `.editorconfig` and `.gitattributes`.
5. Do not make destructive git operations unless explicitly requested.

## Release Logic Expectations

`release-check.yml` supports scheduled and manual runs.

Scheduled run:

1. Resolve latest stable OpenClaw version.
2. Compare against persisted/cached upstream version.
3. Skip when unchanged.
4. Release when changed.
5. Bump patch version for Clawkit release tag.

Manual run:

1. Inputs:
   - `force_release` (boolean)
   - `change_type` (`patch`, `minor`, `major`)
2. Resolve latest stable OpenClaw version.
3. Compare against persisted/cached upstream version.
4. If unchanged and `force_release=false`, skip.
5. If changed or `force_release=true`, release.
6. Bump Clawkit version using `change_type`.

## Agent Working Pattern

When making changes:

1. Read impacted files first.
2. Apply minimal edits.
3. Keep behavior deterministic and easy to audit.
4. Update related docs in the same change.
5. Summarize what changed and why.

## Pre-PR Checklist for Agents

- [ ] Logic changes reflected in docs.
- [ ] No stale references to removed inputs or old behavior.
- [ ] Release workflow conditions still gate build/tag/release steps.
- [ ] New defaults are safe for local users.

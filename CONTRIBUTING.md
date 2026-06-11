# Contributing to Clawkit

This file defines the rules and conventions that **all contributors** — human or AI agent — **must follow** when working on this project.

> Rules are added one at a time as project needs evolve. Each rule is numbered for easy reference.

---

## Project Scope

Clawkit is a Docker image wrapper around OpenClaw with release automation via GitHub Actions.

For runtime and usage details, see [README.md](README.md).

## Rules

### Rule 1 — Branch-then-PR workflow

**Never push directly to `main`.** All changes must follow this workflow:

1. Create a branch from `main`.

- Name format: `<type>/<short-description>`
- Recommended `type` values: `feat`, `fix`, `docs`, `chore`, `refactor`, `hotfix`
- Examples: `feat/add-linuxbrew-cache`, `fix/typo-compose-file`, `docs/update-readme`

2. Make your changes on that branch.
3. Push the branch and open a **Pull Request** (PR) to `main`.
4. Only merge after review.

- For solo work, self-review is acceptable, but a PR is still required.

> `git push origin main` is forbidden unless it is an emergency hotfix explicitly approved by the maintainer.

### Rule 2 — Keep environment docs in sync

If you add, remove, or rename environment variables:

1. Update [.env.example](.env.example) in the correct section.
2. Update [README.md](README.md) configuration notes when user-facing behavior changes.
3. Mention the env change clearly in your PR description.

### Rule 3 — Follow repository formatting conventions

Formatting and line-ending behavior is defined by:

- [.editorconfig](.editorconfig)
- [.gitattributes](.gitattributes)

Key expectations:

- Use spaces, not tabs (except where explicitly required by file type).
- Keep LF line endings.
- Preserve existing style in each file (for example, `Dockerfile` uses 4-space indentation per [.editorconfig](.editorconfig)).

## Prerequisites

Before contributing, ensure you have:

- Git
- Docker Engine
- Docker Compose
- Network access to pull images from GHCR

## Local Validation

Run the validation level that matches your change scope.

### Docs-only changes

If you changed only documentation files (`*.md`), no image build is required.

### Docker, compose, or env changes

For changes to [Dockerfile](Dockerfile), [example-docker-compose.yml](example-docker-compose.yml), or [.env.example](.env.example), validate locally:

1. Build the image:

```bash
docker build -t clawkit:local .
```

2. Start with compose:

```bash
cp .env.example .env
docker compose -f example-docker-compose.yml up -d
```

3. Confirm the container is running and healthy from Docker's perspective:

```bash
docker compose -f example-docker-compose.yml ps
```

4. Stop test containers when done:

```bash
docker compose -f example-docker-compose.yml down
```

## Pull Request Checklist

Before requesting review, verify all applicable items:

- Branch follows `<type>/<short-description>` naming.
- Change description explains what changed and why.
- [.env.example](.env.example) and [README.md](README.md) were updated if env behavior changed.
- Local validation was performed for Docker/compose/env-impacting changes.
- No direct push to `main`.

## Release Context

Releases are automated by [.github/workflows/release-check.yml](.github/workflows/release-check.yml).

- The scheduled run checks upstream OpenClaw changes daily and releases when needed.
- Manual runs can set `force_release` and `change_type` (`patch`, `minor`, `major`).
- If upstream stable version is unchanged and `force_release=false`, the workflow skips release.

---

### Future rules

Additional rules will be appended here as numbered entries (Rule 4, Rule 5, …).

# Improvement Backlog

Tracked improvements for future implementation. Work through these one at a time.

---

## 1 — Add `profiles` key to `docker-compose.yml` (Low)

**Problem:** No compose profiles are defined. Adding one now is a non-breaking change that leaves room for future dev/prod variant files without a breaking rename.

**Fix:** Add `profiles: [default]` under the `openclaw` service in `docker-compose.yml`.

---

## 2 — Rename workflow for clarity (Low)

**Problem:** The workflow is named `Check Upstream and Release`, which only describes the automated path. The manual dispatch path is different in behavior (semver bump, force release).

**Fix:** Rename to `Release Check` in `release-check.yml` (`name:` field). Short, accurate for both paths.

---

## 3 — Note on `.dockerignore` wildcard `*.md` exclusion (Low / awareness)

**Problem:** `.dockerignore` currently excludes all `*.md` files from the Docker build context. This is correct today because no markdown is `COPY`-ed into the image. If a future Dockerfile change needs to `COPY` a markdown file (e.g., a bundled README), it will be silently excluded.

**Fix (when needed):** Add a specific negation rule in `.dockerignore`, for example `!docs/some-file.md`, if a markdown file ever needs to be included in the image build context.

---

## 4 — Attach deploy files as GitHub Release assets (Low / reproducibility)

**Problem:** The deploy path now serves files from `main` via `install.sh`. For
version-locked reproducibility, users may want deploy files that match a
specific release tag.

**Fix (when needed):** Extend the `Create GitHub Release` step in
`.github/workflows/release-check.yml` to `gh release upload` the compose files
and `.env.example` (or a bundled tarball) for each release.

---

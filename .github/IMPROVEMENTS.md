# Improvement Backlog

Tracked improvements for future implementation. Work through these one at a time.

---

## 1 — Add `.dockerignore` to `.gitattributes` (High)

**Problem:** `.dockerignore` was added to the repo but is not listed in `.gitattributes`. Contributors on Windows may commit it with CRLF line endings, which would silently break Docker build context filtering.

**Fix:** Add the following line to `.gitattributes`:

```
.dockerignore text eol=lf
```

---

## 2 — Clarify `OPENCLAW_GATEWAY_TOKEN` is required, not optional (High)

**Problem:** The comment in `.env.example` says "Generate with: openssl rand -hex 32" but does not state that the token is required for the container to authenticate. A user who leaves it empty will deploy a broken container with no obvious error.

**Fix:** Add a `# REQUIRED` annotation or a short note in `.env.example` next to `OPENCLAW_GATEWAY_TOKEN` making it explicit that OpenClaw will not authenticate without it.

---

## 3 — Add a GitHub Pull Request template (High)

**Problem:** `CONTRIBUTING.md` defines a PR checklist, but contributors opening PRs on GitHub get a blank description box. They must remember to apply the checklist manually.

**Fix:** Create `.github/PULL_REQUEST_TEMPLATE.md` pre-filled with the checklist from `CONTRIBUTING.md` so GitHub automatically populates every new PR description with it.

---

## 4 — Replace GHA cache with a persistent GitHub Actions variable for upstream state (Medium)

**Problem:** The workflow stores the last known upstream OpenClaw version in a GitHub Actions cache entry. GHA caches are subject to LRU eviction (10 GB total limit, 7-day TTL). If the cache entry is evicted, the next scheduled run sees no prior state and behaves like a `first_run`, releasing the same version again unnecessarily.

**Fix:** Store `LAST_KNOWN_OPENCLAW_VERSION` as a repository-level Actions variable (`vars.*`) via the GitHub API. Variables are persistent, have no eviction, and are free. The workflow would read the variable at the start and update it via API after a successful release.

Relevant API call to update:

```bash
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /repos/{owner}/{repo}/actions/variables/LAST_KNOWN_OPENCLAW_VERSION \
  -f value="$NEW_VERSION"
```

---

## 5 — Add `profiles` key to `example-docker-compose.yml` (Low)

**Problem:** No compose profiles are defined. Adding one now is a non-breaking change that leaves room for future dev/prod variant files without a breaking rename.

**Fix:** Add `profiles: [default]` under the `openclaw` service in `example-docker-compose.yml`.

---

## 6 — Rename workflow for clarity (Low)

**Problem:** The workflow is named `Check Upstream and Release`, which only describes the automated path. The manual dispatch path is different in behavior (semver bump, force release).

**Fix:** Rename to `Release Check` in `release-check.yml` (`name:` field). Short, accurate for both paths.

---

## 7 — Note on `.dockerignore` wildcard `*.md` exclusion (Low / awareness)

**Problem:** `.dockerignore` currently excludes all `*.md` files from the Docker build context. This is correct today because no markdown is `COPY`-ed into the image. If a future Dockerfile change needs to `COPY` a markdown file (e.g., a bundled README), it will be silently excluded.

**Fix (when needed):** Add a specific negation rule in `.dockerignore`, for example `!docs/some-file.md`, if a markdown file ever needs to be included in the image build context.

---

# Contributing to Clawkit

This file defines the rules and conventions that **all contributors** — human or AI agent — **must follow** when working on this project.

> Rules are added one at a time as project needs evolve. Each rule is numbered for easy reference.

---

## Rules

### Rule 1 — Branch-then-PR workflow

**Never push directly to `main`.** All changes must follow this workflow:

1. Create a **feature branch** from `main`:
   - Name format: `<type>/<short-description>`  
     Examples: `feat/add-linuxbrew-cache`, `fix/typo-compose-file`, `docs/update-readme`
2. Make your changes on that branch.
3. Push the branch and open a **Pull Request** (PR) to `main`.
4. Only merge after review (self-review is acceptable for solo projects — but always use a PR).

> `git push origin main` is **forbidden** unless it's an emergency hotfix explicitly approved by the maintainer.

---

### Future rules

Additional rules will be appended here as numbered entries (Rule 2, Rule 3, …).
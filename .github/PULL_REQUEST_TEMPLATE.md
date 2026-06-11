## Summary

- What changed:
- Why it changed:

## Change Type

- [ ] feat
- [ ] fix
- [ ] docs
- [ ] chore
- [ ] refactor
- [ ] hotfix

## Validation

- [ ] Docs-only change (no image build required)
- [ ] Docker/compose/env-impacting change validated locally

If validated locally, include commands/results briefly:

```bash
# example
# docker build -t clawkit:local .
# docker compose -f example-docker-compose.yml up -d
# docker compose -f example-docker-compose.yml ps
# docker compose -f example-docker-compose.yml down
```

## Checklist

- [ ] Branch follows `<type>/<short-description>` naming
- [ ] Description explains what changed and why
- [ ] Updated `.env.example` and [README.md](../README.md) if env behavior changed
- [ ] No direct push to `main`
- [ ] Release workflow docs remain aligned with `.github/workflows/release-check.yml`

## Risk / Rollback

- Risk level: low / medium / high
- Rollback plan:

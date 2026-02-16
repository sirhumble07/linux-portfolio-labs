# Notes — DevOps Lab 4

## Defensive scripting

- `set -euo pipefail` prevents silent failures.
- validate input arguments
- avoid dangerous deletes (`rm -rf`)

## Why idempotency

Scripts should be safe to rerun:

- during incidents
- in automation loops
- in CI/CD pipelines

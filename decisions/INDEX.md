| 闸门 id | applies-to | 正例 inject.sh | 反例 counter.sh | timing |
|---|---|---|---|---|
| `ADR-20261009-DEPRECATE-must-exist` | `["DEPRECATE.md"]` | yes | yes | post |
| `ADR-20261009-DNA-is-immutable` | `["tools/check-baseline.sh"]` | yes | yes | pre |
| `ADR-20261009-GROWTH-max-3-entries` | `["GROWTH.md"]` | yes | yes | post |
| `ADR-20261009-PLAN-must-exist` | `["PLAN.md"]` | yes | yes | post |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `["PLAN.md"]` | yes | yes | post |
| `ADR-20261009-README-must-carry-the-one-command` | `["README.md"]` | yes | yes | post |
| `ADR-20261009-VISION-must-exist-and-be-a-seed` | `["VISION.md"]` | yes | yes | post |
| `ADR-20261009-appeals-must-be-parseable` | `["ledger/appeals-2026.jsonl"]` | yes | yes | post |
| `ADR-20261009-dangerous-action-shapes-must-be-blocked` | `["DNA.md", "VISION.md", "decisions/**"]` | NO | NO | pre |
| `ADR-20261009-docs-must-be-indexed` | `["docs/INDEX.md"]` | yes | yes | post |
| `ADR-20261009-index-must-be-regenerated` | `["decisions/INDEX.md"]` | yes | yes | post |
| `ADR-20261009-layer1-total-under-280-lines` | `["DNA.md", "RNA.md", "SPEC.md"]` | yes | yes | post |
| `ADR-20261009-ledger-must-be-valid-utf8` | `["ledger/hits-2026.jsonl"]` | yes | yes | post |
| `ADR-20261009-lesson-must-be-replayed` | `["ledger/hits-2026.jsonl"]` | yes | yes | post |
| `ADR-20261009-lesson-must-land-in-artifact` | `["examples/phyt.yml", ".github/workflows/**"]` | yes | yes | post |
| `ADR-20261009-readme-must-carry-the-on-demand-pointer-block` | `["README.md"]` | yes | yes | post |
| `ADR-20261009-shell-var-before-cjk-must-brace` | `["**/*.sh", "decisions/ADR-*.md"]` | yes | yes | post |

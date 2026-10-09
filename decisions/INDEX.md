<!-- 由 `bash tools/validate.sh --index` 生成 —— 不要手改。
     手写的清单会漂（CRITERIA-INVENTORY 的教训）；这份是引擎输出的。 -->

| 闸门 id | applies-to | 正例 inject.sh | 反例 counter.sh | timing |
|---|---|---|---|---|
| `ADR-20261009-DNA-is-immutable` | `["tools/check-baseline.sh"]` | yes | yes | pre |
| `ADR-20261009-GROWTH-max-3-entries` | `["GROWTH.md"]` | yes | yes | post |
| `ADR-20261009-PLAN-must-exist` | `["PLAN.md"]` | yes | yes | post |
| `ADR-20261009-PLAN-must-stay-under-150-lines` | `["PLAN.md"]` | yes | yes | post |
| `ADR-20261009-index-must-be-regenerated` | `["decisions/INDEX.md"]` | yes | yes | post |
| `ADR-20261009-layer1-total-under-280-lines` | `["DNA.md", "RNA.md", "SPEC.md"]` | yes | yes | post |
| `ADR-20261009-lesson-must-be-replayed` | `["ledger/hits-2026.jsonl"]` | yes | yes | post |
| `ADR-20261009-lesson-must-land-in-artifact` | `["examples/phyt.yml", ".github/workflows/**"]` | yes | yes | post |
| `ADR-20261009-shell-var-before-cjk-must-brace` | `["**/*.sh"]` | yes | yes | post |

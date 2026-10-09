# proposals/ —— 已写好、**待人类裁决**的闸门

放这里的闸门**故意不参与心跳**（引擎只跳 `status: deprecated`，不认 `proposed`
⇒ 放进 `decisions/` 就会**单方面把 CI 变红**，而那不该由 agent 决定 —— "门是【授权】，不是【不可能】"）。

## 现有提案

| 闸门 | 缺口 | 取证 |
|---|---|---|
| `ADR-20261009-ledger-must-be-parseable-line-oriented` | 账本 **334 行 / 1069 条记录** ⇒ 不是 JSONL ⇒ 按行读者全错 | `docs/FINDING-2026-10-09-ledger-is-not-jsonl.md`（79 行按行不可解析） |

## 转正步骤（人类一句授权即可）

```bash
git mv proposals/ADR-….md decisions/
git mv proposals/fixtures-ADR-… fixtures/ADR-…
bash tools/validate.sh --index
```
⚠️ 转正前必须先定**迁移方案**：**不得重写既有账本**（append-only：修正 = 追加新记录）。

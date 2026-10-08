---
id: ADR-20261009-cull-after-20-misses
status: accepted
hard: false
effective-from: 2026-10-09
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "v2.1 任务清单 T7：连续 N 个 kind:task 未命中 ∧ 心跳仍红 ⇒ 冷存候选。无名规则不可引用 —— N 必须成文，不写死在引擎里"
risk: normal
cull-after: 20
---

# 连续 N 次未命中的闸门进入冷存候选

## 规则（治理层，hard: false；法官 = `validate.sh --cull`）

1. **N 成文**：`cull-after: 20` —— 连续 **20** 个 `kind:task` 事件中，某条
   `hard: true` 闸门一次未命中，且心跳仍红 ⇒ 列入冷存候选报告
2. **只报告，不自动删**：冷存要人批准（`DEPRECATE.md` 死亡流程），
   `--cull` 永远只输出清单
3. **豁免**：`risk: high` 闸门不出现在清单里（高危闸门豁免频率淘汰）；
   `expires-on` 型闸门不走冷存报告（它们有自己的自动到期机制）
4. 数据来源：`ledger/hits-*.jsonl` 的 `kind: task` 记录（append-only，可审计）

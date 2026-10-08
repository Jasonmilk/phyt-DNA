---
id: ADR-20261009-PLAN-must-stay-under-150-lines
seq: 0003
status: accepted
hard: true
applies-to: ["PLAN.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-PLAN-must-stay-under-150-lines"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "README 硬约束：PLAN ≤150 行（v2.1 从散文结晶为可执行 ADR）"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  [ "$(wc -l < "$F")" -gt 150 ] && echo "$F $(wc -l < "$F") 行 > 150"
last-hit: null
hit-count: 0
supersedes: null
---

# PLAN.md 不得超过 150 行

## 出处

README 硬约束（v1 是散文）："PLAN.md is must-read … Total load ≤280 lines"。
v2.1 把它从**散文**结晶成有 id、有 check、有心跳、会死的 ADR —— V2 的全部价值主张。

## 为什么是 hard:true

- 判定对象是**可枚举的结构化属性**（行数），bash 可精确判定
- PLAN 是唯一 must-read，失控膨胀 = 每个新会话的注意力预算被蚕食（G8）

## 红测

`fixtures/<id>/inject.sh` 追加 151 行 ⇒ 心跳必须报 RED

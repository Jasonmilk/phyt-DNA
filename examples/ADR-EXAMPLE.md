---
id: ADR-20261009-PLAN-must-stay-under-150-lines
seq: 0001
status: accepted
hard: true

# —— 生命 ——
applies-to: ["src/PLAN.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-PLAN-must-stay-under-150-lines"
revisit-on: 2027-04-09
expires-on: null

# —— 治理 ——
owner: "@someone"
origin: "README: PLAN ≤150 lines"
risk: normal

# —— 判定（数据驱动，引擎零硬编码）——
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  [ "$(wc -l < "$F")" -gt 150 ] && echo "$F $(wc -l < "$F") 行 > 150"

last-hit: null
hit-count: 0
supersedes: null
---

# PLAN.md 不得超过 150 行

## 出处
README: "PLAN.md is must-read ... Total load ≤280 lines"

## 为什么是 hard:true
- 每年触发 f ≥ 3 次，单次代价 C ≈ 30 分钟 ⇒ f × C > 年维护成本
- 判定对象是**可枚举的结构化属性**（行数），bash 可精确判定

## 红测
`fixtures/<id>/inject.sh` 注入 >150 行 ⇒ 心跳必须报 RED

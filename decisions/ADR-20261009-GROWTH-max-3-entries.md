---
id: ADR-20261009-GROWTH-max-3-entries
seq: 0005
status: accepted
hard: true
applies-to: ["GROWTH.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-GROWTH-max-3-entries"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "README 硬约束：年轮只保留最近 3 条（GROWTH 头注，v2.1 从散文结晶）"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  n=$(grep -c '^## 年轮 ·' "$F")
  [ "$n" -gt 3 ] && echo "GROWTH 年轮条目 $n > 3（只保留最近 3 条，更早移入 archive/）"
last-hit: null
hit-count: 0
supersedes: null
---

# GROWTH 年轮最多保留 3 条

## 出处

README 硬约束（v1 是散文）："GROWTH.md — growth rings (keep last 3)"。
年轮 = `## 年轮 ·` 开头的条目（`## 年轮格式` 说明段不计入）。

## 为什么

只长不落的树是标本（G6）；年轮是生长记录，不是档案柜 —— 更早的落叶归土进 `archive/`。

## 红测

`fixtures/<id>/inject.sh` 追加 3 个年轮条目 ⇒ 4 > 3 ⇒ 心跳报 RED

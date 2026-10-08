---
id: ADR-20261009-layer1-total-under-280-lines
seq: 0004
status: accepted
hard: true
applies-to: ["DNA.md", "RNA.md", "SPEC.md"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-layer1-total-under-280-lines"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "README 硬约束：layer1 三层合计 ≤280 行 / ≤4500 tokens（RNA §一 三层预算）"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  d=$(dirname "$F")
  t=$(( $(wc -l < "$d/DNA.md") + $(wc -l < "$d/RNA.md") + $(wc -l < "$d/SPEC.md") ))
  [ "$t" -gt 280 ] && echo "layer1 三层合计 $t 行 > 280（DNA+RNA+SPEC）"
last-hit: null
hit-count: 0
supersedes: null
---

# layer1 三层合计 ≤ 280 行

## 出处

README 硬约束（v1 是散文）："Total load: ≤280 lines, ≤4500 tokens"。
RNA §一 三层预算：常量规则(DNA ≤60) + 作用域规则(≤120) + 任务临时(≤100) = **≤280**。

## layer1 定义

DNA.md（基因）+ RNA.md（协议）+ SPEC.md（本体）—— 三个常驻卷的行数合计。
（三条铁律：check 只用 `$F`；禁止 `2>/dev/null`；显式校验输入 —— 行数经由 `$F` 的
目录推导同层文件，重构目录层级不破坏检测。）

## 红测

`fixtures/<id>/inject.sh` 向任一 layer1 文件追加 151 行 ⇒ 合计越过 280 ⇒ 心跳报 RED

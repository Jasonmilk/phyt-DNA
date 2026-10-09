---
id: ADR-20261009-ledger-must-be-parseable-line-oriented
seq: 9010
status: proposed
hard: true
applies-to: ["ledger/hits-2026.jsonl", "ledger/appeals-2026.jsonl"]
effective-from: 2026-10-09
timing: post
redtest: "validate --probe ADR-20261009-ledger-must-be-parseable-line-oriented"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "发现 2026-10-09：账本 334 行含 1069 条记录 ⇒ 不是 JSONL ⇒ 按行读者全错（docs/FINDING-2026-10-09-ledger-is-not-jsonl.md）"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # ★ 具名目标：`ledger/*.jsonl` 是【一句声明】—— 引擎按【首个匹配】解析，
  #   于是闸门可能"通过了"而它命名的另一本账根本没被查（实测 2026-10-09：它落在了干净的那本上）。
  #   ⇒ 故此处【点名】两本，而不是用 glob 概括它们（glob 概括 = 声明代替检查的温床）。
  # 一行一条：按行必须能独立解析。解析不了 ⇒ 具名报出是哪一行、错在哪。
  bad=0
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    if ! printf '%s' "$line" | python3 -c 'import json,sys; json.loads(sys.stdin.read())' 2>/dev/null; then
      bad=$((bad+1))
      [ "$bad" -le 2 ] && echo "账本行不是一条完整 JSON（JSONL 要求一行一条）: $(printf '%s' "$line" | cut -c1-80)…"
    fi
  done < "$F"
  [ "$bad" -gt 0 ] && echo "共 $bad 行按行不可解析 ⇒ 按行读的消费者（grep/闸门引擎/claim-check）会读错"
last-hit: null
hit-count: 0
supersedes: null
---

# 账本必须按行可解析（JSON Lines）

## 出处

发现 2026-10-09（`docs/FINDING-2026-10-09-ledger-is-not-jsonl.md`）：
`ledger/hits-2026.jsonl` 实测 **334 行 / 1069 条记录** ⇒ 记录之间没有换行 ⇒ **不是 JSONL**。

## 为什么

本仓的 SSOT 是账本。**账本读不明白，"每次判定留痕"的读取这一半就是断的**——
证据写进去了、读者读不出来，等于没有。
现有 `ADR-20261009-ledger-must-be-valid-utf8` 只查编码，而它的注释写着"否则读者无法解析该行"：
**意图在解析、检查到编码为止**——这就是"声明代替检查"。
申诉账有解析闸门、主账没有（同类两治），而被漏掉的更要紧。

## 红测

`fixtures/<id>/inject.sh` 造一份**一条记录跨行**的账本 ⇒ 心跳报 RED。
`fixtures/<id>/counter.sh` 做**内容保持**的改动（只改 mtime）⇒ 结论不得改变（否则是"读时钟"的假判据）。

## 状态

**`proposed`** —— 缺口具名，但**是否让 CI 变红由人类裁决**（"门是【授权】，不是【不可能】"）。
转 `accepted` 需同时给出**不重写既有账本**的迁移方案（append-only：修正 = 追加新记录）。

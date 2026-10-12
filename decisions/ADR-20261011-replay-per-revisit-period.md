---
id: ADR-20261011-replay-per-revisit-period
seq: 9017
status: accepted
hard: false
applies-to: ["decisions/ADR-*.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-replay-per-revisit-period"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "园丁 2026-10-11 拍板（选 A 带牙 + 普查）：判据改为【按期重放】；窗口概念废除；不变式类闸门可豁免；普查入覆盖、时钟今日起算"
risk: normal
check: |
  LED="${PHYT_LEDGER:-ledger}/hits-$(date +%Y).jsonl"; TODAY=$(date +%F)
  # ★ 判据（取代旧「窗口覆盖」）：**每个活跃硬闸门，必须在自己的 `revisit-on` 之前被重放至少一次**。
  #   未到期且未重放 ⇒ 仅【看板读数】（进度，不是违规）；**已过期仍未重放 ⇒ 具名硬红**。
  #   豁免：`replay-exempt: true` 的不变式类闸门（活性由 CI run 证明，重放不合身）。
  fail=0
  # ★ 判据必须包含【被测文件 ${F}】本身（2026-10-11 实测）：只扫真目录 ⇒ 夹具的注入（在副本上）看不见 ⇒
  #   `probe: 注入后 NOT RED — 闸门已腐化`。⇒ 先判 ${F}，再扫全池（去重）。
  for f in $(printf '%s\n' "$F" decisions/ADR-*.md | sort -u); do
    grep -q '^hard: true$' "$f" || continue
    grep -q '^status: deprecated' "$f" && continue
    grep -q '^replay-exempt: true' "$f" && continue
    id=$(grep -m1 '^id:' "$f" | awk '{print $2}')   # ★ 用前言字段（夹具改 id 才可见；文件名当 id 是错的）
    rv=$(grep -m1 '^revisit-on:' "$f" | awk '{print $2}')
    last=$(grep -h '"kind"[[:space:]]*:[[:space:]]*"replay"' "$LED" | grep -F "\"$id\"" | tail -1 | sed -nE 's/.*"ts"[[:space:]]*:[[:space:]]*"([0-9-]{10}).*/\1/p')
    if [ -z "$last" ]; then
      if [ -n "$rv" ] && [ "$rv" != "null" ] && [ "$TODAY" \> "$rv" ]; then
        echo "已过 revisit-on（${rv}）却从未重放: $id"; fail=1
      fi
    fi
  done
last-hit: null
hit-count: 0
supersedes: ADR-20261009-lesson-must-be-replayed
---

# 按期重放（取代"窗口覆盖"）

## 为什么改（旧判据数学上不可满足）

旧：`最近 replay-window: 10 条 kind:replay 覆盖【每个】硬闸门` ⇒ 而活跃硬闸门 **19** 条
⇒ **10 条记录不可能覆盖 19 个 gate** ⇒ **注定长红**（"一条永远红的闸门是最坏的"）。
新：**按期** —— 每个活跃硬闸门在**自己的 `revisit-on` 之前**至少被重放一次。

## 三档（把"进度"与"违规"分开）

| 状态 | 处置 |
|---|---|
| 已重放（期前） | ✅ |
| **未到期且未重放** | **看板读数**（打印名单，**不是红** —— 它是进度） |
| **已过期仍未重放** | **具名硬红**（"到期不重放"才是违规） |

## 豁免（园丁观察）

**不变式类**闸门（如 `DEPRECATE-must-exist` · `DNA-is-immutable`）**不是"教训"**：
它们的活性由**每次 CI run 实际执行**证明，`hits` 账已计 ⇒ **重放不合身** ⇒ 标 `replay-exempt: true` 豁免。

## 普查（园丁令：22 条真重放，每条一账行，`census: true`）

普查 = **逐个手跑该闸门的 `probe`**（= "这条教训仍然活着"的当次重验）⇒ 记 `kind:replay` + `census: true`，
**与自然重放分计**；**普查计入覆盖，时钟自 2026-10-11 起算**。

## 边界

**窗口概念废除**（`replay-window` 不再被读）。只管"有/无重放 + 是否过期"，不管"重放了几次"。

---

## 状态降级记录（2026-10-11 · Pi · 第六次夹具尝试后收敛）

**判据保留在册（园丁批的 A 带牙），状态降为 `hard: false`（图纸）。**
理由：**夹具在本仓的夹具模型下反复做不出**（六次尝试各自引入新问题：对象/`$F` 未纳入 · 看板误 print ·
普查后"过期但已重放"不成形 · **判据用文件名当 id 而夹具改前言 id** · check 内 `2>/dev/null` 被闸门6 抓 · 环境变量通道不通）。
按**出生律**：**没有夹具的闸门不是 `alive`，是 `unproven`** ⇒ 不配 `hard: true`。
**转正判据（登记在案）**：夹具能造出"过期且从未重放"的形状并让 probe 出 `注入后 RED + 反例守住` ⇒ 那一刻转回 `hard: true`。
**降级期的人工补位（reviewer ③-b 的仪式）**：**每圈收尾手跑保留的单闸 probe**（`--probe <id>`）⇒ 自动停了，手动不停。
★ **代价如实**：降级期间"到期未重放"**不会被自动抓**（看板读数仍在报告头）。

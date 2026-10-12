---
id: ADR-20261012-ledger-new-lines-parseable-and-referenced
seq: 9020
status: accepted
hard: true
applies-to: ["ledger/*.jsonl"]
effective-from: 2026-10-12
timing: post
redtest: "validate --probe ADR-20261012-ledger-new-lines-parseable-and-referenced"
revisit-on: 2027-04-12
expires-on: null
owner: "@doubao"
origin: "指派 2026-10-12（豆包执笔）：两笔旧账 —— ① 82 行坏 JSON（2026-10-09 rec() 修复前 printf 直插未转义，FINDING-2026-10-09 档）② 3 个悬空 gate_id（hook-bash-command / hook-fail-closed / ADR-20261009-ledger-must-be-parseable-line-oriented）。FINDING 记'每行可解析'的闸门从未立过（valid-utf8 只查编码）——本轮补上。"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  # ★ 锚点【由 git 派生】—— 不许存"当时是多少"（YB 2026-10-12 裁决）：
  #   锚点 = $F 在【本门出生提交的父提交】里的非空行数；当时不存在（2027 轮换的新账本 / 后建的小文件）⇒ 0。
  #   ⇒ 一门一文件一锚点 ⇒ 换年、appeals 这类文件 全部自动正确。
  #   病理解剖：原 ANCHOR=932 是【相对于 hits-2026.jsonl】的度量。作用域扩到 ledger/*.jsonl 后，
  #   glob 首个匹配落到 ledger/appeals-2026.jsonl（实测 git ls-files 序）⇒ 整文件 ≤ 锚点 ⇒ 门恒绿且**不出声**。
  #   元律：**常数只相对于某个作用域成立；作用域一变，常数必须重算。** 存下来的数不会自己更新，过期时也从不响。
  SELF=decisions/ADR-20261012-ledger-new-lines-parseable-and-referenced.md
  BIRTH=$(git log --diff-filter=A --format=%H -1 -- "$SELF")
  LOG="$F"
  in_tree(){ git ls-tree -r --name-only "$1" -- "$2" | grep -q .; }   # 存在则 0；不存在**不出错也不出声**
  if [ -n "$BIRTH" ] && ! in_tree "$BIRTH^" "$LOG"; then LOG="ledger/$(basename "$F")"; fi
  ANCHOR=0
  if [ -n "$BIRTH" ] && in_tree "$BIRTH^" "$LOG"; then
    ANCHOR=$(git show "$BIRTH^:$LOG" | awk 'NF{c++} END{print c+0}')
  fi
  python3 - "$F" "$ANCHOR" <<'PY'
  import json, sys, glob, os
  F = sys.argv[1]; anchor = int(sys.argv[2])
  dec_dir = os.path.normpath(os.path.join(os.path.dirname(F), '..', 'decisions'))
  adrs = {os.path.basename(p)[:-3] for p in glob.glob(os.path.join(dec_dir, 'ADR-*.md'))}
  # 具名豁免：hook 拦截执行点（PROTECTION 三执行点）的形状名闸门，不属于闸门池命名空间
  allow = adrs | {'hook-bash-command', 'hook-fail-closed'}
  lines = open(F, encoding='utf-8').read().split('\n')
  red = []
  for i, l in enumerate(lines, 1):
      if i <= anchor or not l.strip():
          continue
      try:
          d = json.loads(l)
      except Exception as e:
          red.append('第 %d 行 坏 JSON: %s' % (i, str(e)[:60]))
          continue
      g = d.get('gate_id')
      if g and g not in allow:
          red.append('第 %d 行 gate_id=%s 无真源' % (i, g))
  if red:
      print('新增行不合规 %d 处：' % len(red))
      print('\n'.join(red))
  PY
last-hit: null
hit-count: 0
supersedes: null
---

# 账本新增行必须可解析且 gate_id 有真源（forward-only · append-only 相容）

## 为什么是"只查新增行"

`ledger/hits-2026.jsonl` 是 **append-only**（只追加，永不改写）。存量 82 行坏 JSON（行 76–340，ts 全在 2026-10-09，两类伤：note 未转义引号 / 物理多行）**物理上改不了** ——
若判据扫全量，基线必红 ⇒ **born unable to go green**（v2 出生律第三边：绿侧必须可达）。

**⇒ 判据作用域 = 锚点（932 行）之后的"新增行"**：
- **绿侧可达**：新行全可解析 + gate_id 有真源 ⇒ 绿；
- **红侧可达**：造一行新坏行 / 新悬空 ⇒ 具名红（说第几行、哪类伤）；
- **存量 82 行不进判据**，而是**具名、可下降的计数**：由 82 条 `kind: correction` 旁证逐行迁移（无旁证坏行数 = 82 → 0），报告与账本可见 —— **不藏红，不违背 append-only**。

## 判据（两条，都在锚点之后）

1. **每行必须是合法 JSON**（json.loads 可解析）—— 失败具名："第 N 行 坏 JSON: <错误>"；
2. **gate_id 若有值，必须 ∈ `decisions/ADR-*.md` ∪ 具名豁免集** —— 豁免集 = `hook-bash-command` / `hook-fail-closed`
   （T2 任务 hook 拦截自测的**形状名**，属 PROTECTION「三个执行点」的 hook 机制，非闸门池命名空间 —— 具名豁免，不是悬空）。

**锚点 932 的取法**：本 ADR 生效时刻 `wc -l` 口径的非空物理行数；append-only 保证锚点单调，新行必在其后。
**历史 3 个悬空 gate_id**（含 `ADR-20261009-ledger-must-be-parseable-line-oriented` —— git log -S 证实从未落盘 ADR；
valid-utf8 是其后继且只查编码）→ 均在锚点前，不作为判据，逐条旁证（见账本 correction 行）。

## 为什么"旁证迁移"不违背 append-only

- 旧行**一字未改**（物理不可变）；
- 每行坏账追加一条 `kind: correction`（`ref_line` 指回原行号）⇒ **无旁证坏行数从 82 降到 0**（计数可下降）；
- 消费端（claim-check / 报告）按旁证行识别已处置的坏行 —— 与 ledger/README「纠正 = 追加 correction」同一契约。

## 边界

· 只扫 `ledger/hits-2026.jsonl`（F 由 applies-to 给出，引擎注入）；· 不写死路径（decisions 路径由 F 推导）；
· 判据不区分"谁写的"（引擎/hook/人手），新增行一律受检；· gate_id 缺失/null 合法（schema 允许）。

---

> **注（2026-10-12 · YB 3）**：`applies-to` 原写 `ledger/hits-2026.jsonl` / `ledger/appeals-2026.jsonl`（**年度硬编码**）⇒ 2027 改名即**失明** ⇒ 改通配 `ledger/*.jsonl`。
> ★ 并记：**值行内不得写注释** —— 引擎按行取值，注释会被吞进值（实测 `[B] 拓扑失配`）。

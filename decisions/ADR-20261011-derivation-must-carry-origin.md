---
id: ADR-20261011-derivation-must-carry-origin
seq: 9013
status: accepted
hard: true
applies-to: ["decisions/ADR-*.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-derivation-must-carry-origin"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "DNA「派生律的住址」六律之一「派生必带 origin」—— 取证时发现它是六律中【唯一无人守】的一条；而实测 hard:true 18/18 全有 origin ⇒ 可零红上线（立号，见本 ADR）"
risk: normal
check: |
  ROOT=$(git rev-parse --show-toplevel) || { echo "输入失效: 不在 git 工作区（出生日/证据提交不可量）"; exit 4; }
  grep -q '^hard: true$' "$F" || exit 0
  # ★ 0′（2026-10-13）：三要素必须【不可自证】—— 锚定 ^origin: · 提交≠出生提交 · 事件须真 · 证据行须有行号/event_id
  o=$(grep -m1 '^origin:' "$F" | sed 's/^origin: *//')          # ★ 锚定到 ^origin:（禁全文裸匹配）
  case "$o" in ""|'""'|null) echo "派生缺 origin（$(basename "$F")）—— 没有出处的闸门无法追溯" ;; esac
  SELF="$ROOT/decisions/ADR-20261011-derivation-must-carry-origin.md"
  [ -f "$SELF" ] || { echo "输入失效: 本门自身不在（SELF 缺失）⇒ 生效日不可读"; exit 4; }   # ★ SELF 缺失 ⇒ exit 4（不静默跳过）
  EFF=$(grep -m1 '^effective-from:' "$SELF" | sed 's/^effective-from: *//')
  BIRTH=$(cd "$ROOT" && git log --diff-filter=A -1 --format=%cs -- "$F")
  BSHA=$(cd "$ROOT" && git log --diff-filter=A -1 --format=%h -- "$F")
  if [ -n "$BIRTH" ] && [ -n "$EFF" ] && [ "$BIRTH" \> "$EFF" ]; then
    for k in '事件=' '证据行=' '提交='; do
      printf '%s' "$o" | grep -q -- "$k" || echo "④ origin 缺三要素（${k}）（$(basename "$F")）—— 形如 事件=… · 证据行=… · 提交=…"
    done
    c=$(printf '%s' "$o" | sed -n 's/.*提交=\([0-9a-f]\{7,\}\).*/\1/p')
    #   稳健性（同轮补）：引用【全长 40 位 sha】时，取前 7 位与出生 sha 比（7 vs 40 的错位会造成漏判）。
  case "$BSHA" in "$c"*|"${c:0:7}"*) [ -n "$c" ] && echo "④ origin 自证（提交=${c} 就是本 ADR 的出生提交）⇒ 那不是证据，是自己证明自己" ;; esac
    if printf '%s' "$o" | grep -qE '事件=[^·]*(立本门|本轮|我觉得|我认为)'; then
    echo "④ origin 的 事件= 是自造事件（立本门/本轮/我觉得不算）⇒ 须指 task / 真实事故 / 采用 / 园丁裁定"
  fi
    if ! printf '%s' "$o" | grep -qE '证据行=[^·]*(第 ?[0-9]+ ?行|event_id=|task-)'; then
    echo "④ origin 的 证据行= 没有【行号或 event_id】（只给文件名不算证据）"
  fi
  fi
last-hit: null
hit-count: 0
supersedes: null
---

# 派生必带 origin

## 为什么是这条（六律里唯一没人守的那条）

DNA「派生律的住址」列六律。**取证结果**：其中五条**已各有真承载者**——
· **不静默失败** ⇒ `spec-lint` 闸门6（扫 `decisions/*.md` 的 `2>/dev/null`）
· **测试不破坏被测物** ⇒ `spec-lint` 闸门7（ADR-0009 · 扫全量还原命令）
· **外部性降治理层** ⇒ `ADR-…dangerous-action-shapes` + `K34` 的适用范围声明
· **只引用不复制** ⇒ 对齐链实践（五仓 VISION 头部各一行）+ 评审环
· **仪器数字进 ledger** ⇒ 派生视图生成器（`GROWTH.md` 已改指生成物）+ `ledger/*.jsonl`
⇒ 唯独 **派生必带 origin** 无人守 ⇒ 立号。

## 判据（零红上线）

`hard: true` 的 ADR **必须**有非空 `origin:` 字段——**一条闸门凭什么长出来，要留出处**。
**取证时的实测**：`hard:true` 共 **18 条，缺 origin 0 条** ⇒ **本闸门上线即绿**（不是"先红后修"）。
⇒ 这正是立号的最佳时机：**一条律从"没人守"变成"有人守"，而仓库当场合规。**

## 边界（只管硬闸门）

`hard: false`（失败案例索引）不强制 origin —— 它是碎屑，不是闸门。

<!-- probe: 让 INDEX 需要重生 -->

---

## 首考记录（2026-10-12 · 第 4 边第一次真实考试）

**考什么**：`origin-amend` 的三要素必须**机器可核** ——
① 声明的 `提交=` 是真实 commit 对象 ② 声明的 `证据行=` 是 `kind:replay` 且**该行的 `event_id` 与声明逐字吻合**
③ **`grep` 给的行号与声明一致**（工具的读数 对 我的读数）。

**结果**：**PASS × alive**（两条 amend 三要素全核）

**而第一遍是 FAIL —— 机器抓住的是【声明格式歧义】，不是数据错**：
· 正文里出现两个 `event_id=`（轮次事件 + 证据行事件）⇒ 校验器取到第一个 ⇒ 判"不一致"；
· 继而 `commit=` 与 `提交=` 字段名混用 ⇒ 校验器取不到值（脚本自己崩）。
⇒ **⇒ 先定义【可机核的声明格式】，再谈证据**：「事件= / 证据行=（kind · 行 event_id） / 提交=」三段命名。
⇒ 这本身就是第 4 边该产出的东西：**判据不能只说"要有证据"，必须说清"证据怎么被机器读"。**

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
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  grep -q '^hard: true$' "$F" || exit 0
  o=$(sed -n 's/^origin: *//p' "$F" | head -1)
  case "$o" in
    ""|'""'|null) echo "派生缺 origin（$(basename "$F")）—— 没有出处的闸门无法追溯：它凭什么长出来？（派生必带 origin）" ;;
  esac
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

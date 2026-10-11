---
id: ADR-20261011-layer1-budget-is-attention-not-maintenance
seq: 9012
status: accepted
hard: true
applies-to: ["PLAN.md", "RNA.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-layer1-budget-is-attention-not-maintenance"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "园丁 2026-10-11 拍板（选 A + 拆账）：红灯逼出的【修改门】真实使用 —— 一条 ADR + 园丁明确批准"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  d=$(dirname "$F")
  t=$(( $(wc -l < "$d/PLAN.md") + $(wc -l < "$d/RNA.md") ))
  [ "$t" -gt 320 ] && echo "常驻阅读层（PLAN+RNA）合计 $t 行 > 320"
last-hit: null
hit-count: 0
supersedes: ADR-20261009-layer1-total-under-280-lines
---

# layer1 预算 = 【文档注意力】，不是【闸门维护】

## 为什么改（一仆二主）

`≤280` 原来**一个数字服两个主**：

| 成本种类 | 谁承担 | 该由什么表达 |
|---|---|---|
| **文档注意力** | agent **每轮**必须读的东西 | **行数**（本 ADR 的量） |
| **闸门维护** | 人写 + 机器跑 | **`f × C` 经济门槛 + 仪表盘三判据**（`hits/任务` · `override_rate` 按原因 · 心跳红率+新增结晶数） |

两种成本共用一个数字 ⇒ 按下葫芦起了瓢：新 `DNA.md`（148 行）· 新 `SPEC.md`（65 行）落地后
`DNA+RNA+SPEC = 319 > 280` ⇒ **闸门红**，而它们按新设计**根本不是每轮读的**
（`DNA` 做决策时按关键词唤起 · `SPEC` 需要时才加载）。

## 改什么 / 不改什么（单变量）

· **改**：对象 ⇒ `["DNA.md","RNA.md","SPEC.md"]` → **`["PLAN.md","RNA.md"]`**（新设计定义的**常驻阅读层**）。
· **不改**：阈值 **仍 280**（首演后按实际占用校准，不与对象变更混在一起）。
· **闸门的"度"**：不再用行数表达 ⇒ 走 **`f × C` 经济门槛 + 仪表盘三判据**（谓词已存在，不新立闸门）。

## 校准基线（2026-10-11 实测 · 园丁点名要的读数）

```
PLAN.md 59 行 + RNA.md 106 行 = 165 行（阈值 280 ⇒ 余量 115 行）
对照旧对象：DNA 148 + RNA 106 + SPEC 65 = 319（超 39）⇒ 红
```

## 首演校准（园丁授权的第二步 · 单变量：这次只动阈值）

**首演实测（2026-10-11）**：`PLAN.md 59 + RNA.md 229 = 288 行` ⇒ **越过留用的 280**（RNA v2.1 落地所致）。
⇒ 按园丁裁定"**阈值暂留 280，首演后按实际占用校准**"⇒ **本段即那次校准**：**280 → 320**（留 32 行余量，
≈11%），**对象与判据形状不变**（单变量）。
**实测证据链**：hook 测试的 `写 PLAN.md ⇒ 期望 exit=0` 因此转红（`hook_test: 8 passed, 1 failed`）⇒
证明**该闸门真的在拦**（不是纸面阈值）；校准后应复归绿。

## 与老 ADR 的关系（supersede 的走法）

新 ADR 立（`hard: true` · 新对象）+ 老 ADR 的 `status` 改为 **`deprecated`** ——
**引擎自己开了这个口子**：`gates()` 里有 `grep -q '^status: deprecated' && continue`。
`status` 是**生命周期字段**，不是正文 ⇒ 与「`decisions/` 冻结、改 = supersede，不改原文」相容。
老 ADR 的正文与出处**原样保留**（它是 v1 三层预算的历史真源）。

## 附：`seq` 命名规则（微点① · 2026-10-11 取证）

实测 `decisions/` 的 seq 分布：**`9002–9012` = v2 世代**（本 ADR 为 `9012`）；
更早的 v1 世代用 `0001–0004`（如被本 ADR supersede 的 `ADR-20261009-layer1-total-under-280-lines` = `0004`）。
**规则一句话**：`seq` 按**世代分段**（v1: 000X · v2: 900X），同段内递增；改名不重编（id 是终身身份）。

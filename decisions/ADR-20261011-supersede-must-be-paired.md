---
id: ADR-20261011-supersede-must-be-paired
seq: 9018
status: accepted
hard: true
applies-to: ["decisions/ADR-*.md"]
effective-from: 2026-10-11
timing: post
redtest: "validate --probe ADR-20261011-supersede-must-be-paired"
revisit-on: 2027-04-11
expires-on: null
owner: "@jason"
origin: "reviewer ⑤（2026-10-11）核心提案 + 本周两案：① 静默回滚把 deprecated 翻回 accepted ② supersede 只做前半（老 ADR 未标死）⇒ 两案都是它能抓的红"
risk: normal
check: |
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  d=$(dirname "$F"); id=$(grep -m1 '^id:' "$F" | awk '{print $2}')
  # 方向一：本条 supersedes 了谁 ⇒ 对端必须已 deprecated
  sup=$(grep -m1 '^supersedes:' "$F" | awk '{print $2}')
  if [ -n "$sup" ] && [ "$sup" != "null" ]; then
    t="$d/$sup.md"
    if [ ! -f "$t" ]; then echo "supersedes 指向不存在的 ADR: ${sup}（本条 ${id}）"; 
    elif ! grep -q '^status: deprecated' "$t"; then echo "supersede 只做了一半：${id} 取代了 ${sup}，但对端仍是 accepted ⇒ 双闸并存"; fi
  fi
  # 方向二：本条若 deprecated ⇒ 必须有后继（某条 ADR 的 supersedes 指向我）
  if grep -q '^status: deprecated' "$F"; then
    if ! grep -l "^supersedes: ${id}$" "$d"/ADR-*.md >/dev/null 2>&1; then
      echo "死而无后：${id} 标了 deprecated，却没有任何后继声明的 ${id} ⇒ 退役没有落款"
    fi
  fi
last-hit: null
hit-count: 0
supersedes: null
---

# supersede 必须【配对】（两半动作 · 含出生律第三边首演）

## 为什么（本周两案）

| 案 | 症状 | 本闸门是否抓得住 |
|---|---|---|
| **静默回滚** | 探针的 `git checkout -- decisions/` 把 `deprecated` **翻回** `accepted`（作案点 `682b115`） | ✅ 方向二（deprecated 消失 = 后继失去对端…… 反向亦然，见判据两方向） |
| **只做前半** | 新 ADR 带 `supersedes:` 而**老 ADR 未标 deprecated** ⇒ 坏的那条**继续在跑**（最后一条基线红就是它） | ✅ 方向一 |

## 双向判据

· **本条 `supersedes: X`** ⇒ **X 必须 `status: deprecated`**（否则"只做一半 ⇒ 双闸并存"）。
· **本条 `status: deprecated`** ⇒ **必须存在某条 ADR 声明 `supersedes: 本条id`**（否则"死而无后 ⇒ 退役没有落款"）。

## ★ 出生律第三边【首演】（reviewer ⑦）

出生律原两边：**能红**（注入）· **反例守住**（counter）。缺的第三边是 **可绿** —— 即"**合规态可达且验绿**"。
本闸门是它的第一个应用场地：**构造一对合法的 supersede（新 + 老 deprecated）⇒ 必须绿**；
而"半对"（只立新不标死）⇒ 必须红。⇒ **两边都构造得出来**，故本条自出生起三边齐（夹具见 `fixtures/`）。

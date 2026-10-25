---
id: ADR-20261023-borrowing-must-name-the-gap
seq: 9028
status: accepted
hard: true
applies-to: ["decisions/ADR-*.md"]
effective-from: 2026-10-23
timing: post
redtest: "bash tools/validate.sh --probe ADR-20261023-borrowing-must-name-the-gap"
revisit-on: 2027-04-23
expires-on: null
owner: "@jason"
origin: "真实经历（2026-10-23 沙盒取证）：吸收 JM-Zen 时逐条比对，发现 phyt-DNA 借鉴了 Nygard/MADR/SemVer 等巨人，但**全仓 `origin` 里『缺口』出现 0 次** —— 我们只记『我从哪来』，从不记『我哪里和它不一样、它哪里我不敢用』。事件=自生长闭环立项 · 差异=本门只管『借鉴型 origin』的缺口登记，不管决策质量本身 · 缺口=覆盖不到"读了巨人但没把来源写进 origin"的**隐性借鉴**（本仓现状即此类）· 证据行=ledger/hits-2026.jsonl:2545 · 提交=6b5fdf3"
risk: normal
probe: yes
check: |
  # 只审【借鉴型】origin：带了来源标记，就必须同时交代【差异】与【缺口】。
  # 为什么只审借鉴型：现状 35 条 ADR 的 origin 绝大多数是"真实经历"，不是借鉴；
  #   若一律要求三要素 ⇒ 上线即红一片（那不是守门，那是砸门）。
  #   ⇒ 与 ADR-20261011-derivation-must-carry-origin「零红上线」同一惯例：法只管它管得住的那一层。
  # ⚠️ 块内容【必须每行都以空格开头】：check_of 的 awk 遇顶格行即判定"块已结束" ⇒ check 被截断。
  [ -f "$F" ] || { echo "输入失效: $F 不存在（静默失败=伪证）"; }
  grep -q '^hard: true$' "$F" || exit 0
  o=$(grep -m1 '^origin:' "$F" | sed 's/^origin: *//')
  case "$o" in ""|'""'|null) exit 0 ;; esac
  printf '%s' "$o" | grep -qE '来源=|借鉴|参考' || exit 0      # 非借鉴型 ⇒ 不归本门
  for k in '差异=' '缺口='; do
    printf '%s' "$o" | grep -q -- "$k" ||
      echo "④ 借鉴缺三要素（${k}）（$(basename "$F")）—— 来源=… · 差异=… · 缺口=… 三者缺一不可：只记『我从哪来』，不记『我哪里不同、哪里不敢用』，那是没有出处的借鉴"
  done
last-hit: null
hit-count: 0
supersedes: null
---

# 借鉴必须点名【缺口】

## 为什么

`DNA.md`：**参考巨人是复用的知识形态——借鉴成熟实践，不照抄专名。**

但实证：**全仓 `origin` 里「缺口」出现 0 次。**
我们借鉴 Nygard / MADR / SemVer / JM-Zen，只记"我从哪来"，
从不记**"我哪里和它不一样"**与**"它哪里我不敢用"**。

⇒ 后果：下一次有人拿同一份巨人来提建议时，
**没人知道哪些部分已经被试过、哪些被有意放弃** ⇒ 同一个争论重开一遍。
这正是"不比就建是浪费"的翻版：**不记缺口，就是在给未来的重复劳动留门。**

## 判据

`origin` 里出现来源标记（`来源=` / `借鉴` / `参考`）⇒ 必须同时含 **`差异=`** 与 **`缺口=`**。

| 要素 | 回答什么 |
|---|---|
| `来源=` | 我从哪来 |
| `差异=` | 我哪里和它不一样（以及为什么） |
| `缺口=` | 它有的哪部分我**没有落地** ⇒ 别把它当成已经具备的能力 |

## 为什么只审借鉴型（零红上线）

现状 35 条 ADR 里，带来源标记的**只有 1 条**，且它已带全三要素 ⇒ **基线绿**。
若一律要求三要素 ⇒ 上线即红一片 ⇒ 那不是守门是砸门，
而且会训练人忽略红灯（警报疲劳——`sync-upstream.sh` 注释里自己警告过的那件事）。

⇒ 与 `ADR-20261011-derivation-must-carry-origin`（取证 18/18 全有 ⇒ 零红上线）同一惯例：
**法只管它管得住的那一层，其余留给下一轮结晶。**

## 边界

- 只审 `hard: true` 的 ADR；图纸（`hard: false`）的自述不归本门。
- 只查 `origin` 字段，**不解析正文**（格式是契约的载体，字段即契约）。
- 判据只读不写。

## 红测

`fixtures/<id>/inject.sh` 造一份带 `来源=` 但缺 `差异=`/`缺口=` 的 ADR ⇒ 必须红；
`counter.sh` 只在注释里加字（不改 `origin` 值）⇒ 必须不红。

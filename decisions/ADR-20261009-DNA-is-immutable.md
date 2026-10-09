---
id: ADR-20261009-DNA-is-immutable
seq: 0006
status: accepted
hard: true
applies-to: ["tools/check-baseline.sh"]
effective-from: 2026-10-09
timing: pre
redtest: "validate --probe ADR-20261009-DNA-is-immutable"
revisit-on: 2027-04-09
expires-on: null
owner: "@jason"
origin: "README 硬约束：DNA 不可直接编辑（改基因 = 修宪 = 走 ADR + 人批准）"
risk: normal
check: |
  # 元闸门（P9 第一例）：断言"DNA 的不可变性【由机制守着】"，**不断言 DNA 的内容**。
  # 必须问工具的【真实 scope 输出】—— 不得 grep 源码文本（否则又盯错对象，第 29 条同源）。
  s=$(bash tools/check-baseline.sh --scope)
  printf '%s\n' "$s" | grep -qx 'DNA.md' || echo "元闸门失守: DNA.md 不在资产基线 scope 内 ⇒ 改基因将无人拦"
last-hit: null
hit-count: 0
supersedes: null
---

# DNA 不可变（路径黑名单）

> **⚠️ 本题目的措辞过强，2026-10-09 更正**：准确说法是 **「DNA 的改动要过【授权门】」**，
> 不是"不可能改"。人类更正：*"DNA 不是不能改，需要申请、明确需要改，那就可以改。
> 只是未获得明确授权之前不能改。"* ——**门是授权，不是不可能**。
> **id 不改**（改名会牵动 INDEX 与各处引用 ⇒ "修完这边坏了那边"），仅在此更正表述。

## 出处

README 硬约束 + DNA.md 头注："本文件不可直接编辑。改基因 = 修宪 = 走 ADR + 人批准。"

## timing: pre 的原因

PreToolUse 时**读不到未来内容**，只能判路径 —— 所以本闸门是路径黑名单
（`applies-to: ["DNA.md"]`），不是内容判定。事后全仓扫描（CI）只跑 post 型，本闸门天然豁免。

## 红测

`fixtures/<id>/inject.sh` 写入任意内容（pre 型不看内容）⇒ 路径命中 ⇒ 心跳报 RED

---
id: ADR-20261009-readme-must-carry-the-on-demand-pointer-block
seq: 9010
status: deprecated
hard: false
supersedes: null
superseded-by: ADR-20261009-readme-must-be-a-truthful-entry
applies-to: ["README.md"]
timing: post
effective-from: 2026-10-09
revisit-on: null
expires-on: null
owner: "@jasonmilk"
origin: "v1 遗产（2026-10-09 立）：README 必须带【按需指针块】。2026-10-12 被 ADR-20261009-readme-must-be-a-truthful-entry 取代（改名 + 判据扩到四件）。"
risk: normal
check: |
  :   # deprecated ⇒ 引擎 gates() 跳过本门；此 check 仅为满足 ADR 形状。判据不许在这里改（改就改新门）。
last-hit: null
hit-count: 0
---

# ADR-20261009-readme-must-carry-the-on-demand-pointer-block（**已废弃 · 保留为真源**）

**本门 2026-10-12 被 [`ADR-20261009-readme-must-be-a-truthful-entry`](ADR-20261009-readme-must-be-a-truthful-entry.md) 取代**（改名 + 判据从"指针块一件"扩到"四件"）。

**为什么保留本文件，而不是删掉或改名**（园丁 2026-10-12 裁定 0）：

1. **账本 append-only**：`ledger/hits-2026.jsonl` 里有数十行旧 `gate_id` 指向本 id ⇒ 删掉或改名会让它们**悬空**，
   而旧行**物理不可改** ⇒ 只能让 id 继续有真源。
2. **配对可执行**：`deprecated` ⇒ 必须有后继声明它（新门的 `supersedes:` 指向本 id）。
3. **教训**：**改名要走 supersede 路径**（旧文件留 deprecated 存根），**不要直接改 id** ——
   我 2026-10-12 先做了后者，才会需要"具名历史豁免"那种补丁；本文件把那个补丁撤掉。

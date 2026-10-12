---
kind: truth-source-removal-record
removed: hits-2026.jsonl（仓库根）
date: 2026-10-12
kept: ledger/hits-2026.jsonl
---

# 指针记录：根目录 `hits-2026.jsonl`（**第二真值源，已删**）

**为什么删**：同一个账本曾有**两份**（根目录 1130 行 vs `ledger/` 1137 行）⇒ **两个真值源 = 没有真值源**
（读者取哪个都能自圆其说）。裁定：**保留 `ledger/hits-2026.jsonl`**（`rec()` 写它、闸门读它、`applies-to` 指它）。

**它为什么该删而不是留**：实测它**独有的 3 行**里有 2 行是**夹具注入垃圾**（`gate_id: ghost-gate-xyz`）
⇒ 它不是"更早的账本"，是**被污染的分叉**。内容在 git 历史里可取：`git show <旧 commit>:hits-2026.jsonl`。

**根因**：引擎 `LED_DIR="${PHYT_LEDGER:-ledger}"` 默认正确 ⇒ 该分叉来自**早期版本或某次显式 `PHYT_LEDGER=.`** 的运行
（未追到确证 ⇒ 记为"未证实"）。

#!/usr/bin/env bash
# 注入（★ 2026-10-12 改）：**就地**把被测 ADR 的 status 从 deprecated 翻回 accepted ⇒ 它与取代者的 pair 就断了。
# ★ 为什么不再造新文件：旧版往 `dirname($F)` 写一条假 ADR ⇒ **当 harness 交来真路径时就污染了真仓**
#   （实测：`decisions/ADR-99999999-injected-predecessor.md` 漏进真仓，且被 git 跟踪 ⇒ 资产基线 BLOCK）。
#   ⇒ 教训：**夹具不得在"可能为真"的路径上创建对象**（"夹具必须活在引擎能看到的世界里"的反面边界）。
sed -i.bak -E 's/^status: deprecated/status: accepted/' "$F" && rm -f "$F.bak"

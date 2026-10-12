#!/usr/bin/env bash
# 注入（★ 2026-10-12 改：不创建任何文件）：**把被测 ADR 的 `supersedes:` 改指一条【仍 accepted】的 ADR**
# ⇒ pair 半对（对端不是 deprecated）⇒ 闸门必须红。
# ★ 旧版往 `dirname($F)` 写一条假 ADR ⇒ **probe-all 每跑一次就往真仓落一个对象**（实测污染两次、资产基线 BLOCK）。
#   教训：**夹具不得在"可能为真"的路径上创建对象** —— 现在改为纯就地编辑。
sed -i.bak -E 's/^supersedes: .*/supersedes: ADR-20261009-claim-needs-redtest/' "$F" && rm -f "$F.bak"

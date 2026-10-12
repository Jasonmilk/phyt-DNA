#!/usr/bin/env bash
# 反例（★ 2026-10-12 补 · YB 1）：**追加一条【合法】新行 ⇒ 必须仍绿**。
# 为什么原有的 `touch` 不够：本门的判据是"锚点之后的新增行必须合法 JSON" ⇒
# 只测"内容不变的改动不改变结论"**测不到**最可能的坏形状：**"凡新增必红"**（那样判据就错了，却会一直绿）。
# ⇒ 反例必须**与判据同形**：合法追加 ⇒ 结论不变（绿）。
printf '{"ts":"2026-10-12T00:00:00+0800","kind":"probe","gate_id":null,"event_id":"counter-legal-append","verdict":"pass","override":false,"source":"cli","note":"counter: a LEGAL append must keep the verdict GREEN"}\n' >> "$F"

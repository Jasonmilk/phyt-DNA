#!/usr/bin/env bash
# inject.sh — 真形状：往账本尾追加【锚点后】的坏行（两类伤各一行：坏 JSON / 悬空 gate_id）。
# ★ 不持久污染：probe_one 在 check 前后各备份/还原一次（cp /tmp/inj.bak "$F"），本注入会被还原。
#   （与 ledger-utf8 夹具同构；2026-10-12 起按"夹具不得持久创建对象"纪律，还原由引擎保证。）
set -eu
: "${F:?fixture needs $F}"
printf '{"ts":"2026-10-12T23:59:59+0800","gate_id":"ghost-gate-xyz","kind":"probe","note":"坏 "unclosed 引号"}\n' >> "$F"
printf '{"ts":"2026-10-12T23:59:59+0800","gate_id":"ghost-gate-xyz","kind":"probe","note":"悬空 gate_id 样例"}\n' >> "$F"

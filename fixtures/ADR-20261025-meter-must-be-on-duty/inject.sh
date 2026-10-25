#!/usr/bin/env bash
# inject.sh — 真形状：追加一条【电表未上工】的 run 行（缺 elapsed_ms · per_gate 缺类 · 总额不符）。
# 这正是 A-5 修复前那 44/70 条的历史形状 ⇒ 该红。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_meter_backup
printf '{"ts":"2026-10-25T00:00:00+0800","kind":"run","source":"ci-local","caller":"ci-local","timing":"post","elapsed_ms":0,"files":10,"judged_gates":5,"valid":"true","invariant_schema":"v1","judged_ids":"a b c","per_gate":{"judged-green":"a b c d e f g"},"verdicts":{"pass":9,"block":1,"other":0}}\n' >> "$F"

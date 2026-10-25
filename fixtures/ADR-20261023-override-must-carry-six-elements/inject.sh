#!/usr/bin/env bash
# inject.sh — 真形状：往账本追加一行【一句话放行】（缺 signer / 日落 / 补偿 / 回退）。
# 这正是旧通道允许的形状（note 默认「无理由」）⇒ 该红。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_override_backup
printf '{"ts":"2026-10-23T00:00:00+0800","kind":"override","gate_id":"ADR-20261023-probe","verdict":"block","override":true,"source":"cli","event_id":"ov-probe-inject","note":"临时放行一下"}\n' >> "$F"

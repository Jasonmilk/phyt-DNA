#!/usr/bin/env bash
# inject.sh — 真形状：写一行【不该被写进申诉账的东西】（半条 JSON）——
# 与 hits 那次事故同族（`$var（` 把多字节字符切坏）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_appeals_backup
printf '{"ts":"2026-10-09T00:00:00+0800","gate_id":"ADR-…","verdict":"appeal",\n' >> "$F"

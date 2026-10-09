#!/usr/bin/env bash
# counter.sh — 内容不变的改动（touch）不得改变结论。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_counter_index_backup 2>/dev/null || true
if touch -t 202001010000 "$F" 2>/dev/null; then :; else touch "$F"; fi

#!/usr/bin/env bash
set -eu
: "${F:?fixture needs $F}"
# 反例：内容不变的改动（仅 mtime 变化）不得触发判据 —— 判据读内容，不读时钟。
if touch -t 202001010000 "$F" 2>/dev/null; then :; else touch "$F"; fi

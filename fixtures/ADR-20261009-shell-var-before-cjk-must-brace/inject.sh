#!/usr/bin/env bash
# inject.sh — 注入一条真实形状：$var 后紧跟全角括号（跳注释的判据应能检出它）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_brace_backup
printf '\necho "… $value（上限）"\n' >> "$F"

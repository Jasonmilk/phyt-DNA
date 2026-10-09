#!/usr/bin/env bash
# inject.sh — 让 INDEX 与生成器不一致（真实形状：改了闸门没重新生成）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_index_backup
printf '| `ADR-20260999-stale-row` | `["nowhere"]` | yes | yes | post |\n' >> "$F"

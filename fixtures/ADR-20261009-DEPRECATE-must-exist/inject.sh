#!/usr/bin/env bash
# inject.sh — 真形状：入口/机制文档被清空（比删除更常见，也更难被发现）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_ADR_20261009_DEPRECATE_must_exist_backup
: > "$F"

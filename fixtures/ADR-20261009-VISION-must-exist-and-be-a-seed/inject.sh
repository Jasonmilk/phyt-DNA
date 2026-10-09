#!/usr/bin/env bash
# inject.sh — 真形状：种子被清空（只剩空行）—— 比删除更常见，也更难被发现。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_vision_backup
: > "$F"

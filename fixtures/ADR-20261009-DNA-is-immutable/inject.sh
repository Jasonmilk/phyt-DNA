#!/usr/bin/env bash
# inject.sh — 判据（审查给定）：**从 scope 里删掉 DNA.md ⇒ 必须红。不红 ⇒ 仍是装饰品。**
# 注入作用于闸门的检测对象：tools/check-baseline.sh（元闸门守的就是它）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_scope_backup
sed -i '' 's/find decisions tools DNA.md/find decisions tools/' "$F" 2>/dev/null || sed -i 's/find decisions tools DNA.md/find decisions tools/' "$F"

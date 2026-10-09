#!/usr/bin/env bash
# inject.sh — 注入形如 `$var` 后紧跟全角括号的一行。
#
# ★ 夹具【不得字面包含】它要注入的违规：那条闸门 applies-to **/*.sh ⇒ 若本文件里出现字面形状，
#   闸门会扫到【夹具自己】（CI 第 4 步实测抓到过）。故用 %s 拼接，运行时才产出违规形状。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_brace_backup
printf '\necho "… $value%s\n' "（上限）" >> "$F"

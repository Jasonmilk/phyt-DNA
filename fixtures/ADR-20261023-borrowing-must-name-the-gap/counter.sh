#!/usr/bin/env bash
# counter.sh — 【内容未变】的改动：只在正文末尾追加一行不改变 origin 的说明。
# 判据读的是 `origin` 字段 ⇒ 结论必须与改动前相同（不变即不红）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_counter_borrow_backup
printf '\n<!-- counter: 本行只加注释，不改 origin 值 -->\n' >> "$F"

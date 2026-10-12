#!/usr/bin/env bash
# 正例：往 PLAN 里塞一条"已完成" ⇒ 必须变红（计划只放未完成）
set -eu
: "${F:?fixture needs $F (the file under test)}"
printf '\n| **X9** | 夹具注入的已完成条目 | ✅ 完成 |\n' >> "$F"

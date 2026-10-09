#!/usr/bin/env bash
# counter.sh —— THE NEGATIVE FIXTURE: 内容保持的改动不得改变结论。
# 只改 mtime（不动字节）⇒ 若判据读了时钟就会误报，该回归才看得见。
set -eu
: "${F:?fixture needs $F (the file under test)}"
if touch -t 202001010000 "$F" 2>/dev/null; then :; else touch "$F"; fi

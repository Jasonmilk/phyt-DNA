#!/usr/bin/env bash
# counter.sh —— THE NEGATIVE FIXTURE: 内容保持的改动不得改变结论（只改 mtime）。
set -eu
: "${F:?fixture needs $F (the file under test)}"
if touch -t 202001010000 "$F" 2>/dev/null; then :; else touch "$F"; fi

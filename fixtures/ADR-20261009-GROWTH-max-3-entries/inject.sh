#!/usr/bin/env bash
# 正例：加第 4 条「年轮」而不归档 ⇒ 必须变红（判据是"溢出必须真归档"，不是"条数 ≤ 3"）
set -eu
: "${F:?fixture needs $F (the file under test)}"
printf '\n## 年轮 · 2026-10-12（夹具注入：第 4 条）\n\n夹具注入的占位年轮，用于证明本门能红。\n' >> "$F"

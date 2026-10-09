#!/usr/bin/env bash
# inject.sh —— THE POSITIVE FIXTURE: 注入"坏东西"必须变红。
# 坏东西 = 一条记录**跨行**（JSONL 的下限：一行一条）。用临时文件，绝不动真账本。
set -eu
: "${F:?fixture needs $F (the file under test)}"
bak="$(mktemp)"
printf '{"ts":"2026-10-09T00:00:00+0800","gate_id":"x","verdict":"pass",\n"kind":"probe"}\n' >> "$bak"
cp "$F" "${bak}.orig" 2>/dev/null || true
cp "$bak" "$F"

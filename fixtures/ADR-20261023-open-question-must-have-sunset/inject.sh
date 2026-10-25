#!/usr/bin/env bash
# inject.sh — 真形状：落一条【没有日落、没有答复者、没有默认动作】的问句。
# 这正是 RNA.md:13「请园丁确认」的现状形状 ⇒ 该红。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_question_backup
printf '{"ts":"2026-10-11T00:00:00+0800","kind":"question","gate_id":"null","verdict":"open","override":false,"source":"cli","event_id":"q-probe-inject","topic":"RNA.md#%s","note":"请园丁确认"}\n' "送审状态" >> "$F"

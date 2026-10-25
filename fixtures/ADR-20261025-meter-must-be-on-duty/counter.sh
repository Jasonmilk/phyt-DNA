#!/usr/bin/env bash
# counter.sh — 内容一个字节都不改（只 touch）⇒ 判据必须给出与改动前相同的结论。
set -eu
: "${F:?fixture needs $F}"
if touch -t 202001010000 "$F"; then :; else touch "$F"; fi

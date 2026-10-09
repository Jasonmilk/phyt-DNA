#!/usr/bin/env bash
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_counter_ledgerutf8_backup 2>/dev/null || true
if touch -t 202001010000 "$F" 2>/dev/null; then :; else touch "$F"; fi

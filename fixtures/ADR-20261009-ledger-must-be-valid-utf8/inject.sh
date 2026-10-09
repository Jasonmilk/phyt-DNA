#!/usr/bin/env bash
# inject.sh — 真形状：往账本里写一行含残缺字节的记录（正是那次事故的形状）。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_ledgerutf8_backup
printf '{"kind":"probe","note":"残缺字节 %b"}\n' '\xbc\x88' >> "$F"

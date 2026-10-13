#!/usr/bin/env bash
# 正例（2026-10-13 · ②-8 派生 + ②尾巴）：**阈值与注入量都由真仓现状派生，不写死任何数**。
#   阈值读【门自己那条 ADR 的判据】（`-gt N`）；归档数读 `archive/growth/` 里的**年轮型**文件；
#   注入到 `TH + arch + 1` 条 ⇒ 恰好让"溢出比归档多 1" ⇒ **自动越阈**（归档/阈值一变，夹具自己跟着变）。
set -eu
: "${F:?fixture needs $F (the file under test)}"
ADR="decisions/ADR-20261009-GROWTH-max-3-entries.md"
TH=$(grep -oE -- '-gt [0-9]+' "$ADR" | head -1 | awk '{print $2}')
[ -n "$TH" ] || { echo "夹具无法从 ADR 派生阈值（判据形态变了？）" >&2; exit 4; }
live=$(grep -c '^## 年轮 ·' "$F")
arch=0
for g in archive/growth/*.md; do
  [ -e "$g" ] || continue
  grep -q '^## 年轮' "$g" && arch=$((arch+1))
done
target=$(( TH + arch + 1 ))
need=$(( target - live ))
[ "$need" -lt 1 ] && need=1
i=0
while [ "$i" -lt "$need" ]; do
  i=$((i+1))
  printf '\n## 年轮 · 2026-10-13（夹具派生注入 #%d/%d · live=%d · arch=%d · TH=%d）\n\n派生注入。\n' "$i" "$need" "$live" "$arch" "$TH" >> "$F"
done

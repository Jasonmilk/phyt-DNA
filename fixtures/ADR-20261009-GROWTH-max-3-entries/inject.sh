#!/usr/bin/env bash
# 正例（2026-10-13 · ②-8）：**注入量由真仓现状派生**，不写死。
#   判据 = "年轮 n>3 时，溢出 (n-3) 必须真归档" ⇒ 所以要越阈，必须让 **n-3 > 归档数**。
#   ⇒ 注入到 `3 + 归档 + 1` 条（= 恰好让"溢出比归档多 1"）⇒ **边界样本**（②-7）。
set -eu
: "${F:?fixture needs $F (the file under test)}"
live=$(grep -c '^## 年轮 ·' "$F")
arch=0
for g in archive/growth/*.md; do
  [ -e "$g" ] || continue
  grep -q '^## 年轮' "$g" && arch=$((arch+1))
done
target=$(( 3 + arch + 1 ))
need=$(( target - live ))
[ "$need" -lt 1 ] && need=1
i=0
while [ "$i" -lt "$need" ]; do
  i=$((i+1))
  printf '\n## 年轮 · 2026-10-13（夹具派生注入 #%d/%d · live=%d · arch=%d）\n\n派生注入。\n' "$i" "$need" "$live" "$arch" >> "$F"
done

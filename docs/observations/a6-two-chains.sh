#!/usr/bin/env bash
# A-6 两条链判定器（观测层 · 2026-10-13）· 用法: bash a6-two-chains.sh <账本夹具> [给定N]
set -u
f="$1"; N="${2:-}"
c1=$(sed -n "${N}p" "$f" 2>/dev/null | python3 -c '
import sys,json
try: d=json.load(sys.stdin)
except Exception: print("RED 坏JSON/空行"); raise SystemExit
cls=["judged-green","judged-red","unmeasurable","skipped-by-timing","skipped-by-cache"]
bad=[]
if d.get("kind")!="run": bad.append("非run行")
if int(d.get("elapsed_ms",0))<=0: bad.append("elapsed_ms<=0")
if int(d.get("files",0))<=0: bad.append("files<=0")
pg=d.get("per_gate") or {}
for k in cls:
    if k not in pg: bad.append("缺"+k)
print("RED "+",".join(bad) if bad else "PASS")' 2>/dev/null || echo "RED chain1-error")
n2=$(grep -nE '"kind"[[:space:]]*:[[:space:]]*"run"' "$f" | tail -1 | cut -d: -f1)
c2=$(awk -v N="${n2:-0}" '
BEGIN{split("judged-green judged-red unmeasurable skipped-by-timing skipped-by-cache",C," ");bad=""}
NR==N{
  if ($0 !~ /"kind"[ \t]*:[ \t]*"run"/) bad=bad "非run行 "
  if ($0 !~ /"elapsed_ms"[ \t]*:[ \t]*[1-9]/) bad=bad "elapsed_ms<=0 "
  if ($0 !~ /"files"[ \t]*:[ \t]*[1-9]/) bad=bad "files<=0 "
  for (i=1;i<=5;i++) if (index($0,"\"" C[i] "\"")==0) bad=bad "缺" C[i] " "
}
END{ if (N==0) bad="找不到run行 "; print (bad=="" ? "PASS" : "RED " bad) }' "$f")
printf '  %-20s N=%-4s 链1: %-30s 链2: %s\n' "$(basename "$f")" "${N:-自动}" "$c1" "$c2"

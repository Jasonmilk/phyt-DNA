#!/usr/bin/env bash
# A-6 两条链判定器（观测层 · 2026-10-13/14）
#   用法: bash a6-two-chains.sh <账本夹具> [给定N]
#   链1 = A-6 自身形态：N 由**外部给定**（"脚本内我写的那一行"）+ sed -n "${N}p" + python 一组断言
#   链2 = 独立链：N 由 **grep -n（[[:space:]] 可移植写法）现求** + python **另一套**字段/类型判据
#   ★ 两条链**不共享逻辑**（N 机制不同、断言集合不同）；**共享环境依赖 = `python3`**（可移植性所需）。
#   ★ 可移植性：只用 shell 内建 + git + python3 + grep 的基本 ERE（[[:space:]]）；**不用 GNU 专属**（grep -P / sed -r / awk \s / sort -V …）。
set -u
f="$1"; N="${2:-}"

# ── 链1（A-6 自身形态）
c1=$(sed -n "${N}p" "$f" 2>/dev/null | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print("RED 坏JSON/空行"); raise SystemExit
bad = []
if d.get("kind") != "run": bad.append("非run行")
if int(d.get("elapsed_ms", 0)) <= 0: bad.append("elapsed_ms<=0")
if int(d.get("files", 0)) <= 0: bad.append("files<=0")
pg = d.get("per_gate") or {}
for k in ["judged-green", "judged-red", "unmeasurable", "skipped-by-timing", "skipped-by-cache"]:
    if k not in pg: bad.append("缺" + k)
# ★ B（2026-10-14 · DS 二④ 独立性重定义）：**链1 查"计数-列表"关系**（第六类：语义错）
ids = (pg.get("judged-green") or "").split()
try:
    if int(d.get("judged_gates", -1)) != len(ids): bad.append("judged_gates(%s)!=列表长度(%d)" % (d.get("judged_gates"), len(ids)))
except Exception:
    bad.append("judged_gates 非整数")
for v in (d.get("verdicts") or {}).values():
    try:
        if int(v) < 0: bad.append("verdicts<0")
    except Exception:
        bad.append("verdicts非数")
print("RED " + ",".join(bad) if bad else "PASS")
' 2>/dev/null || echo "RED chain1-error")

# ── 链2（独立链）：N 现求 + 另一套判据
n2=$(grep -nE '"kind"[[:space:]]*:[[:space:]]*"run"' "$f" | tail -1 | cut -d: -f1)
c2=$(python3 - "$f" "${n2:-0}" <<'PY'
import sys, json
path, N = sys.argv[1], int(sys.argv[2] or 0)
if N == 0:
    print("RED 找不到run行"); raise SystemExit
line = None
with open(path, encoding='utf-8', errors='replace') as fh:
    for i, l in enumerate(fh, 1):
        if i == N:
            line = l.strip(); break
if not line:
    print("RED 行号越界"); raise SystemExit
try:
    d = json.loads(line)
except Exception:
    print("RED 该行不是合法 JSON"); raise SystemExit
bad = []
if d.get("kind") != "run": bad.append("非run行")
for k in ["elapsed_ms", "files", "judged_gates"]:
    v = d.get(k)
    if not isinstance(v, int) or v <= 0: bad.append("%s 非正整数" % k)
pg = d.get("per_gate")
if not isinstance(pg, dict):
    bad.append("per_gate 非对象")
else:
    for k in ["judged-green", "judged-red", "unmeasurable", "skipped-by-timing", "skipped-by-cache"]:
        if k not in pg: bad.append("缺" + k)
        elif not isinstance(pg[k], str): bad.append(k + " 非字符串")
v = d.get("verdicts")
if not isinstance(v, dict):
    bad.append("verdicts 非对象")
else:
    for k, n in v.items():
        if not isinstance(n, int) or n < 0: bad.append("verdicts.%s 非非负整数" % k)
print("RED " + ",".join(bad) if bad else "PASS")
PY
)

printf '  %-20s N=%-4s 链1: %-34s 链2: %s\n' "$(basename "$f")" "${N:-自动}" "$c1" "$c2"

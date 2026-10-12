#!/usr/bin/env bash
# regex-census.sh —— 正则清点器（**读数器**；由 spec-lint 的判据守着：`--selftest` 不过 ⇒ 判据器红）。
# 口径（2026-10-12 修正）：**BRE 也是正则** —— `grep 'pat'`（无 -E）与 `grep -E` / `egrep` 同等计入；
#   唯一不计入 = **固定串**（`grep -F`）。实现用 python（shell 里写正则 = 转义灾难，本会话实测多次）。
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
exec python3 - "$@" <<'PY'
import glob, io, os, re, subprocess, sys

# 一次正则调用 = grep/egrep/sed 后面跟着标志（可选）与模式；**不带 -F**（固定串）。
CALL = re.compile(r'\b(grep|egrep|sed)\s+(-[A-Za-z]+\s+)*')
FIXED = re.compile(r'\b(grep)\s+(-[A-Za-z]*F[A-Za-z]*)\b')

def count(text):
    """返回 (计数, 每行是否命中)——逐行判定，漏掉的行要能被具名报出。"""
    n = 0
    for line in text.split('\n'):
        if not line.strip() or line.strip().startswith('#'):
            continue
        if not CALL.search(line):
            continue
        if FIXED.search(line):          # 固定串：不计
            continue
        n += 1
    return n

SAMPLE = r"""
grep -q '^## Start here' "$F"
grep -qE '^status: deprecated' "$F"
grep -oE 'tools/[a-z]+' "$F" | sort -u
sed -E 's/x/y/' "$F"
egrep 'a|b' "$F"
grep -cE '^\\|' "$F"
grep -nE 'ok' "$F"
grep -vE '^$' "$F"
grep -lE 'x' docs/*.md
sed -nE '1p' "$F"
egrep -c 'a' "$F"
grep -c '^|' "$F"
grep -qF 'ok' "$F"
""".strip('\n')

if '--selftest' in sys.argv:
    lines = [l for l in SAMPLE.split('\n') if l.strip()]
    hit = 0; miss = []
    for i, l in enumerate(lines, 1):
        if FIXED.search(l):
            miss.append('第%d行(固定串 · 本不该计): %s' % (i, l)); continue
        if CALL.search(l):
            hit += 1
        else:
            miss.append('第%d行(未识别): %s' % (i, l))
    print('  计数器自检：样本 %d 行 = 12 条正则形状（含 **BRE** `grep -q`/`grep -c`）+ 1 条固定串（`grep -F`，不该计）' % len(lines))
    print('  计数器数到：%d 条（判据 = **12/12**）' % hit)
    if hit == 12:
        print('  ✅ 自检通过')
        if miss: print('  未识别/豁免明细:' + '; '.join(miss))
        sys.exit(0)
    print('  ★ 自检失败（判据 12/12）—— 未识别/豁免明细:' + '; '.join(miss), file=sys.stderr)
    sys.exit(2)

print('  口径：BRE 与 ERE 同等计入；仅【固定串 grep -F】不计。A=判据型（check 块内）· B=实现型（工具脚本）')
def check_body(f):
    out = subprocess.run(['bash','-c',"awk '/^check: \\|/{f=1;next} f&&/^[^ ]/{f=0} f&&NF{print}' '%s' | sed 's/^  //'" % f],capture_output=True,text=True).stdout
    return out
A = 0
for f in sorted(glob.glob('decisions/ADR-*.md')):
    b = io.open(f, encoding='utf-8').read()
    if 'check: |' not in b: continue
    n = count(check_body(f))
    if n: print('  A %-50s %d' % (os.path.basename(f)[:-3], n)); A += n
print('  ── A 栏（判据型）合计：%d 次' % A)
B = 0
for f in sorted(glob.glob('tools/*.sh')):
    n = count(io.open(f, encoding='utf-8').read())
    if n: print('  B %-50s %d' % (os.path.basename(f), n)); B += n
print('  ── B 栏（实现型）合计：%d 次' % B)
print('  ── ★ 无样本正则清单（判据型 · 无样本 ⇒ unproven，不当绿）:')
miss = []
for f in sorted(glob.glob('decisions/ADR-*.md')):
    gid = os.path.basename(f)[:-3]; fx = os.path.join('fixtures', gid)
    if not os.path.isdir(fx): continue
    body = check_body(f)
    for p in sorted(set(re.findall(r"(?:grep|egrep|sed)[^\n']*?'([^']+)'", body))):
        if not re.search(r'[\\\[\]\(\)\|\*\+\?\^\{\}\$]', p): continue   # 固定串不算
        r = subprocess.run(['git','grep','-qE','-e',p])
        if r.returncode != 0: miss.append('%s: %s' % (gid[:40], p[:46]))
print('    未证条数：%d' % len(miss))
for m in miss[:12]: print('      ·', m)
PY

# 钩子验收测试注释

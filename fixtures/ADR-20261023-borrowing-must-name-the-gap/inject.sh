#!/usr/bin/env bash
# inject.sh — 真形状：把一条 ADR 的 origin 改成【只写来源、不写差异与缺口】。
# 这正是吸收巨人时的常见形状（"我参考了 X" ⇒ 完）⇒ 该红。
set -eu
: "${F:?fixture needs $F}"
cp "$F" /tmp/_probe_borrow_backup
python3 - "$F" <<'PY'
import io, sys
p = sys.argv[1]
lines = io.open(p, encoding='utf-8').read().split('\n')
for i, l in enumerate(lines):
    if l.startswith('origin:'):
        lines[i] = 'origin: "来源=MADR 4.x（依赖图与 front matter 规范）"'
        break
io.open(p, 'w', encoding='utf-8').write('\n'.join(lines))
PY

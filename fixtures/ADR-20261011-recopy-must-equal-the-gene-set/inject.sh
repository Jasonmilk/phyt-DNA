#!/usr/bin/env bash
# 注入：把【最新一条】"名目重抄"行里的第一个名目改错 ⇒ 必须红（漂移的形状）
# ★ 必须改【最后一条】：本闸门只判最新那条（2026-10-11 与实现同步修正）
python3 - "$F" <<'PY'
import io, sys
p=sys.argv[1]; lines=io.open(p,encoding='utf-8').read().split('\n')
idx=[i for i,l in enumerate(lines) if '名目重抄' in l]
i=idx[-1]
lines[i]=lines[i].replace('：小步可验证','：小步可验证【被篡改】',1)
io.open(p,'w',encoding='utf-8').write('\n'.join(lines))
PY

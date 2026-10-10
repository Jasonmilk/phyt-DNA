#!/usr/bin/env bash
# inject.sh —— THE POSITIVE FIXTURE: 破坏【英文按需指针】块 ⇒ 必须变红。
# 教训（都留在注释里）：
#  ① 临时产物放 /tmp，**绝不在被文件旁留 .bak**（对齐既有夹具惯例）。
#  ② 用 python 改文本，不用 grep -v 配多字节 pattern（BSD grep 在 C locale 下匹配不到中文
#     ⇒ 夹具"注入成功"却没删东西 ⇒ 探针会报「闸门已腐化」）。
set -eu
: "${F:?fixture needs $F (the file under test)}"
python3 - "$F" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
s = s.replace('## Start here', '## X').replace('The question you are asking', 'X').replace('docs/INDEX.md', 'X')
io.open(p, 'w', encoding='utf-8').write(s)
PY

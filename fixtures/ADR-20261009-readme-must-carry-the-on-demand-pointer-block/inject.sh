#!/usr/bin/env bash
# inject.sh —— THE POSITIVE FIXTURE: 破坏「按需指针」块 ⇒ 必须变红。
# 两个教训都写在这里：
#  ① 临时产物放 /tmp，**绝不在被文件旁留 .bak**（对齐既有夹具惯例）。
#  ② 用 **python** 改文本，不用 grep -v 配多字节 pattern —— BSD grep 在 C locale 下
#     匹配不到中文 pattern（实测：夹具"注入成功"却没删掉任何东西 ⇒ 探针报"闸门已腐化"）。
set -eu
: "${F:?fixture needs $F (the file under test)}"
python3 - "$F" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding='utf-8').read()
# 破坏三个必需特征（块标识 / 表头 / 指向 docs/INDEX.md）
s = s.replace('按需指针', 'X').replace('我要回答的问题', 'X').replace('docs/INDEX.md', 'X')
io.open(p, 'w', encoding='utf-8').write(s)
PY

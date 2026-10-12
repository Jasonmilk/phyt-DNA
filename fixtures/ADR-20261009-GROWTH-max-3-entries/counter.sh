#!/usr/bin/env bash
# 反例（与判据同形）：**内容改动但不加年轮条目** ⇒ 结论必须不变。
# 只测"内容不变"是不够的：判据对"条数"敏感，反例就必须证明"改内容不改条数 ⇒ 不红"。
set -eu
: "${F:?fixture needs $F (the file under test)}"
printf '\n<!-- counter: 一次内容改动，不新增年轮条目 -->\n' >> "$F"

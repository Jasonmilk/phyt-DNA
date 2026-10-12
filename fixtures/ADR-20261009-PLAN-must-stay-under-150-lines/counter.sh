#!/usr/bin/env bash
# 反例（与判据同形）：加一条【未完成】条目 ⇒ 结论必须不变（绿）
set -eu
: "${F:?fixture needs $F (the file under test)}"
printf '\n| **X9** | 夹具注入的未完成条目 | ⬜ 待做 |\n' >> "$F"
